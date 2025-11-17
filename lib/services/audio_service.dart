import 'dart:async';
import 'dart:io' show Platform, Process;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import '../models/alert_type.dart';
import 'storage_service.dart';

class AudioService {
  static AudioService? _instance;
  
  final AudioPlayer _player = AudioPlayer();
  final StorageService _storageService = StorageService();
  bool _isPlaying = false;
  DateTime? _continuousStartTime;
  Timer? _stopTimer;
  final List<Function(bool)> _playingListeners = [];
  AlertType _defaultAlertType = AlertType.single;

  // Private constructor
  AudioService._();

  // Singleton instance getter
  static AudioService get instance {
    _instance ??= AudioService._();
    return _instance!;
  }

  bool get isPlaying => _isPlaying;
  AlertType get defaultAlertType => _defaultAlertType;

  /// Ses çalma durumu değişikliği için listener ekler.
  void addPlayingListener(Function(bool) listener) {
    _playingListeners.add(listener);
    // Mevcut durumu hemen bildir
    listener(_isPlaying);
  }

  /// Ses çalma durumu değişikliği listener'ını kaldırır.
  void removePlayingListener(Function(bool) listener) {
    _playingListeners.remove(listener);
  }

  /// Tüm listener'lara ses çalma durumu değişikliğini bildirir.
  void _notifyPlayingChanged(bool isPlaying) {
    for (final listener in _playingListeners) {
      listener(isPlaying);
    }
  }

  /// Varsayılan alarm tipini yükler.
  Future<void> loadDefaultAlertType() async {
    final index = await _storageService.loadDefaultAlarmAlertType();
    _defaultAlertType = AlertType.values[index];
  }

  /// Varsayılan alarm tipini günceller.
  Future<void> updateDefaultAlertType(AlertType alertType) async {
    _defaultAlertType = alertType;
    await _storageService.saveDefaultAlarmAlertType(alertType.index);
  }

  /// Uyarı sesi çalar.
  /// Default alert type kullanır (ayarlardan değiştirilebilir).
  /// Single için 200ms sonra otomatik durur, continuous için 60 saniye çalar.
  Future<void> playAlert() async {
    final alertType = _defaultAlertType;
    // Önce mevcut çalmayı durdur (sadece önceki continuous beep'i durdur)
    _isPlaying = false;
    _continuousStartTime = null;
    _stopTimer?.cancel();
    _stopTimer = null;

    if (alertType == AlertType.single) {
      _isPlaying = true;
      _notifyPlayingChanged(true);
      await _playSingleBeep();
      // Single için 200ms sonra durdur
      _stopTimer?.cancel();
      _stopTimer = Timer(const Duration(milliseconds: 200), () {
        _isPlaying = false;
        _notifyPlayingChanged(false);
      });
    } else if (alertType == AlertType.continuous) {
      // Continuous beep'i await etmeden başlat (background'da çalışsın)
      unawaited(_playContinuousBeep());
    }
  }

  /// Tek bir bip sesi çalar.
  /// Sistem bip sesi kullanılır. Windows'ta çalışmazsa alternatif yöntemler denenir.
  Future<void> _playSingleBeep() async {
    try {
      // Sistem bip sesi çal
      SystemSound.play(SystemSoundType.alert);
      // Ses çalması için kısa bir bekleme
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      // Windows'ta SystemSound çalışmıyorsa alternatif denemesi
      if (Platform.isWindows) {
        try {
          // Windows'ta beep sesi çal
          await Process.run('powershell', ['[console]::beep(800, 200)']);
        } catch (e2) {
          // Eğer bu da çalışmazsa, en azından denemiş olduk
        }
      }
    }
  }

  /// 60 saniye boyunca sürekli bip sesi çalar.
  /// Her 500ms'de bir bip sesi tekrarlanır.
  Future<void> _playContinuousBeep() async {
    // Kısa bir gecikme ver ki önceki loop dursun
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Yeni continuous beep'i başlat
    _isPlaying = true;
    _continuousStartTime = DateTime.now();
    _notifyPlayingChanged(true);

    // 60 saniye sonra otomatik durdur
    _stopTimer?.cancel();
    _stopTimer = Timer(const Duration(seconds: 60), () {
      if (_isPlaying) {
        _isPlaying = false;
        _continuousStartTime = null;
        _notifyPlayingChanged(false);
      }
    });

    // 60 saniye boyunca tekrarlayan bip
    while (_isPlaying && 
           _continuousStartTime != null && 
           DateTime.now().difference(_continuousStartTime!).inSeconds < 60) {
      if (!_isPlaying) break;
      
      try {
        await _playSingleBeep();
      } catch (e) {
        // Hata olsa bile devam et
      }
      
      if (_isPlaying) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (_isPlaying) {
      _isPlaying = false;
      _continuousStartTime = null;
      _notifyPlayingChanged(false);
    }
  }

  /// Çalan sesi durdurur.
  /// Sürekli çalan alarm sesi kesilir.
  void stop() {
    _isPlaying = false;
    _continuousStartTime = null;
    _stopTimer?.cancel();
    _stopTimer = null;
    _player.stop();
    _notifyPlayingChanged(false);
  }

  void dispose() {
    stop();
    _playingListeners.clear();
    _player.dispose();
  }
}

