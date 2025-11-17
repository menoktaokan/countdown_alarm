import 'package:flutter/material.dart';
import '../models/countdown_model.dart';
import '../services/countdown_service.dart';
import '../services/alarm_service.dart';
import '../services/audio_service.dart';
import '../utils/time_formatter.dart';
import '../widgets/system_clock.dart';
import '../widgets/alarm_indicator.dart';

class CountdownFullscreen extends StatefulWidget {
  final CountdownModel countdown;
  final CountdownService countdownService;
  final AlarmService alarmService;

  const CountdownFullscreen({
    super.key,
    required this.countdown,
    required this.countdownService,
    required this.alarmService,
  });

  @override
  State<CountdownFullscreen> createState() => _CountdownFullscreenState();
}

class _CountdownFullscreenState extends State<CountdownFullscreen> {
  Duration? _remainingTime;
  bool _isAlarmPlaying = false;
  late final Function(bool) _alarmPlayingListener;

  @override
  void initState() {
    super.initState();
    // Mevcut kalan süreyi servisten al - startTime'a göre hesapla
    if (widget.countdownService.currentCountdown != null) {
      final countdown = widget.countdownService.currentCountdown!;
      if (countdown.startTime != null && !countdown.isPaused) {
        final now = DateTime.now();
        final elapsed = now.difference(countdown.startTime!);
        final totalDuration = countdown.totalDuration;
        final calculatedRemaining = totalDuration - elapsed;
        _remainingTime = calculatedRemaining.inSeconds > 0 ? calculatedRemaining : Duration.zero;
      } else {
        _remainingTime = countdown.remainingTime ?? countdown.totalDuration;
      }
    } else {
      _remainingTime = widget.countdown.remainingTime ?? widget.countdown.totalDuration;
    }
    
    // Alarm çalma durumu listener'ını ayarla - doğrudan AudioService'den dinle
    _isAlarmPlaying = AudioService.instance.isPlaying;
    _alarmPlayingListener = (bool isPlaying) {
      if (mounted) {
        setState(() {
          _isAlarmPlaying = isPlaying;
        });
      }
    };
    AudioService.instance.addPlayingListener(_alarmPlayingListener);
    
    _setupListener();
  }

  /// Geri sayım servisinin callback'lerini ayarlar.
  /// onTick ve onComplete olayları için listener'lar kurulur.
  void _setupListener() {
    widget.countdownService.onTick = (countdown, remaining) {
      if (mounted) {
        setState(() {
          _remainingTime = remaining;
        });
      }
    };

    widget.countdownService.onComplete = (countdown) {
      if (mounted) {
        setState(() {
          _remainingTime = Duration.zero;
        });
        // Ses çalma işlemi CountdownService tarafından AudioService'e istek atılarak yapılıyor
        // Geri sayım bittiğinde ana ekrana dön (opsiyonel)
        // Navigator.of(context).pop();
      }
    };
    
    // İlk yüklemede kalan süreyi güncelle
    _updateRemainingTime();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ekran geri döndüğünde kalan süreyi servisten güncelle
    _updateRemainingTime();
  }

  void _updateRemainingTime() {
    if (widget.countdownService.currentCountdown != null) {
      final currentRemaining = widget.countdownService.currentCountdown!.remainingTime;
      if (currentRemaining != null) {
        setState(() {
          _remainingTime = currentRemaining;
        });
      }
    }
  }

  /// Ekrana tıklandığında çağrılır.
  /// Geri sayımın duraklat/devam durumunu değiştirir.
  void _handleTap() {
    widget.countdownService.togglePause();
    if (mounted) {
      setState(() {});
    }
  }


  /// Geri butonuna tıklandığında çağrılır.
  /// Geri sayımı iptal eder ve ana ekrana döner.
  void _handleBack() {
    widget.countdownService.stopCountdown();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = widget.countdownService.currentCountdown?.isPaused ?? false;
    final displayTime = _remainingTime ?? Duration.zero;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sistem saati (üst ortada)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Center(
                      child: SystemClock(),
                    ),
                  ),
                  const SizedBox(height: 20),
              // Geri sayım zamanı
              Text(
                TimeFormatter.formatCountdown(displayTime),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
              const SizedBox(height: 40),
              // Duraklatıldı göstergesi
              if (isPaused)
                Text(
                  'Duraklatıldı',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              const SizedBox(height: 60),
              // Geri butonu
              IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 32,
                onPressed: _handleBack,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
                ],
              ),
            ),
          ),
          // Alarm çalma göstergesi (sağ altta)
          if (_isAlarmPlaying) const AlarmIndicator(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    AudioService.instance.removePlayingListener(_alarmPlayingListener);
    super.dispose();
  }
}

