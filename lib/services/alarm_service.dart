import 'dart:async';
import '../models/alarm_model.dart';
import '../models/alert_type.dart';
import 'audio_service.dart';

class AlarmService {
  final AudioService _audioService = AudioService.instance;
  
  Timer? _checkTimer;
  AlarmModel? _activeAlarm;
  
  Function(AlarmModel)? onAlarmTriggered;
  Function(AlarmModel)? onAlarmSet;
  Function(AlarmModel)? onAlarmCancelled;

  AlarmModel? get activeAlarm => _activeAlarm;
  bool get hasActiveAlarm => _activeAlarm != null && _activeAlarm!.isActive;
  AlertType get defaultAlertType => _audioService.defaultAlertType;
  bool get isAlarmPlaying => _audioService.isPlaying;

  /// Alarm çalma durumu değişikliği için listener ekler.
  /// AudioService'den dinler.
  void addAlarmPlayingListener(Function(bool) listener) {
    _audioService.addPlayingListener(listener);
  }

  /// Alarm çalma durumu değişikliği listener'ını kaldırır.
  void removeAlarmPlayingListener(Function(bool) listener) {
    _audioService.removePlayingListener(listener);
  }

  void setAlarm(AlarmModel alarm) {
    // Mevcut alarmı iptal et
    cancelAlarm();
    
    _activeAlarm = alarm.copyWith(
      isActive: true,
    );
    _startChecking();
    onAlarmSet?.call(_activeAlarm!);
  }

  void updateAlarm(AlarmModel alarm) {
    if (_activeAlarm == null) return;
    
    _activeAlarm = _activeAlarm!.copyWith(
      hour: alarm.hour,
      minute: alarm.minute,
    );
    _startChecking();
  }

  Future<void> updateDefaultAlertType(AlertType alertType) async {
    await _audioService.updateDefaultAlertType(alertType);
  }

  Future<void> loadDefaultAlertType() async {
    await _audioService.loadDefaultAlertType();
  }

  void _startChecking() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeAlarm == null || !_activeAlarm!.isActive) {
        return;
      }

      final now = DateTime.now();

      if (now.hour == _activeAlarm!.hour && 
          now.minute == _activeAlarm!.minute &&
          now.second == 0) {
        _triggerAlarm();
      }
    });
  }

  void _triggerAlarm() {
    if (_activeAlarm == null) return;

    // AudioService'e istek at, ses çalma durumu yönetimi AudioService'de
    _audioService.playAlert().catchError((error) {});
    
    onAlarmTriggered?.call(_activeAlarm!);
  }
  
  /// Aktif alarmı iptal eder.
  /// Timer durdurulur, ses kesilir ve alarm tamamen kaldırılır.
  void cancelAlarm() {
    if (_activeAlarm == null) return;

    final alarm = _activeAlarm!;
    _activeAlarm = null;
    _audioService.stop();
    _checkTimer?.cancel();
    onAlarmCancelled?.call(alarm);
  }

  /// Alarm sesini durdurur.
  /// Sürekli çalan alarm sesi kesilir.
  void stop() {
    _audioService.stop();
  }

  void dispose() {
    _checkTimer?.cancel();
    // AudioService singleton olduğu için dispose edilmemeli
  }
}

