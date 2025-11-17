import 'dart:async';
import '../models/countdown_model.dart';
import 'audio_service.dart';

class CountdownService {
  final AudioService _audioService = AudioService.instance;
  
  Timer? _timer;
  CountdownModel? _currentCountdown;
  int _currentRepeatCount = 0;
  
  Duration? _remainingTime;
  Function(CountdownModel?, Duration?)? onTick;
  Function(CountdownModel)? onComplete;

  CountdownModel? get currentCountdown => _currentCountdown;
  bool get isRunning => _timer != null && _timer!.isActive && !(_currentCountdown?.isPaused ?? true);
  bool get hasActiveCountdown => _currentCountdown != null;

  /// Geri sayımı başlatır.
  /// Eğer zaten aktif bir geri sayım varsa, önceki geri sayımı durdurur.
  void startCountdown(CountdownModel countdown) {
    // Mevcut geri sayımı durdur
    stopCountdown();

    _currentCountdown = countdown.copyWith(
      startTime: DateTime.now(),
      isPaused: false,
      remainingTime: countdown.totalDuration,
    );
    _remainingTime = countdown.totalDuration;
    _currentRepeatCount = 0;

    _startTimer();
  }

  /// Geri sayım timer'ını başlatır.
  /// Her saniye kalan süreyi azaltır ve onTick callback'ini çağırır.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCountdown == null || _currentCountdown!.isPaused) {
        return;
      }

      if (_currentCountdown!.startTime != null) {
        final now = DateTime.now();
        final elapsed = now.difference(_currentCountdown!.startTime!);
        final totalDuration = _currentCountdown!.totalDuration;
        final calculatedRemaining = totalDuration - elapsed;
        
        if (calculatedRemaining.inSeconds <= 0) {
          _remainingTime = Duration.zero;
          _currentCountdown = _currentCountdown!.copyWith(remainingTime: Duration.zero);
          onTick?.call(_currentCountdown, Duration.zero);
          _handleComplete();
          return;
        }
        
        _remainingTime = calculatedRemaining;
        _currentCountdown = _currentCountdown!.copyWith(remainingTime: _remainingTime);
        onTick?.call(_currentCountdown, _remainingTime);
      } else {
        if (_remainingTime == null || _remainingTime!.inSeconds <= 0) {
          _handleComplete();
          return;
        }

        _remainingTime = Duration(seconds: _remainingTime!.inSeconds - 1);
        _currentCountdown = _currentCountdown!.copyWith(remainingTime: _remainingTime);
        onTick?.call(_currentCountdown, _remainingTime);

        if (_remainingTime!.inSeconds <= 0) {
          _handleComplete();
        }
      }
    });
  }

  void _handleComplete() {
    _timer?.cancel();
    
    if (_currentCountdown == null) return;

    // AudioService'e ses çalma isteği at (default alert type kullanılır)
    _audioService.playAlert().catchError((error) {});
    
    onComplete?.call(_currentCountdown!);

    // Geri sayım tamamlandı, temizle
    _currentCountdown = null;
    _currentRepeatCount = 0;
  }

  /// Aktif geri sayımı duraklatır.
  /// Timer durdurulur.
  void pauseCountdown() {
    if (_currentCountdown == null) return;

    _timer?.cancel();
    _currentCountdown = _currentCountdown!.copyWith(isPaused: true);
  }

  /// Duraklatılmış geri sayımı devam ettirir.
  /// Timer yeniden başlatılır.
  void resumeCountdown() {
    if (_currentCountdown == null || !_currentCountdown!.isPaused) return;

    // Duraklatıldığında geçen süreyi hesapla ve startTime'ı güncelle
    if (_currentCountdown!.startTime != null && _currentCountdown!.remainingTime != null) {
      final now = DateTime.now();
      final originalDuration = _currentCountdown!.totalDuration;
      final elapsed = originalDuration - _currentCountdown!.remainingTime!;
      
      // startTime'ı güncelle ki timer doğru hesaplasın
      _currentCountdown = _currentCountdown!.copyWith(
        isPaused: false,
        startTime: now.subtract(elapsed), // Geçen süreyi koru
        remainingTime: _currentCountdown!.remainingTime,
      );
      _remainingTime = _currentCountdown!.remainingTime;
    } else {
      _currentCountdown = _currentCountdown!.copyWith(isPaused: false);
    }
    
    _startTimer();
  }

  /// Aktif geri sayımı tamamen durdurur.
  /// Timer temizlenir.
  void stopCountdown() {
    _timer?.cancel();
    _currentCountdown = null;
    _remainingTime = null;
    _currentRepeatCount = 0;
  }

  /// Geri sayımın duraklat/devam durumunu değiştirir.
  /// Eğer duraklatılmışsa devam ettirir, çalışıyorsa duraklatır.
  void togglePause() {
    if (_currentCountdown == null) return;

    if (_currentCountdown!.isPaused) {
      resumeCountdown();
    } else {
      pauseCountdown();
    }
  }


  void dispose() {
    _timer?.cancel();
    // AudioService singleton olduğu için dispose edilmemeli
  }
}

