import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/countdown_circle.dart';
import '../widgets/alarm_circle.dart';
import '../widgets/system_clock.dart';
import '../widgets/alarm_indicator.dart';
import '../models/countdown_model.dart';
import '../models/alarm_model.dart';
import '../services/countdown_service.dart';
import '../services/alarm_service.dart';
import '../services/audio_service.dart';
import 'countdown_fullscreen.dart';
import 'alarm_fullscreen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CountdownService _countdownService = CountdownService();
  final AlarmService _alarmService = AlarmService();
  bool _isAlarmPlaying = false;
  late final Function(bool) _alarmPlayingListener;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _loadDefaultAlertType();
  }

  /// Varsayılan alarm tipini yükler.
  Future<void> _loadDefaultAlertType() async {
    await _alarmService.loadDefaultAlertType();
  }

  /// Servis callback'lerini ayarlar.
  /// Geri sayım ve alarm olayları için listener'lar kurulur.
  void _setupListeners() {
    _countdownService.onTick = (countdown, remaining) {
      if (mounted) {
        setState(() {});
      }
    };

    _countdownService.onComplete = (countdown) {
      if (mounted) {
        setState(() {});
      }
    };

    // Ana sayfada alarm listener'larına gerek yok
    // Alarm sadece fullscreen'de aktif

    _alarmPlayingListener = (bool isPlaying) {
      if (mounted) {
        setState(() {
          _isAlarmPlaying = isPlaying;
        });
      }
    };
    // Doğrudan AudioService'den dinle
    AudioService.instance.addPlayingListener(_alarmPlayingListener);
  }

  /// Geri sayım başlatıldığında çağrılır.
  /// Mevcut alarmı iptal eder, geri sayımı başlatır ve tam ekran görünümü açılır.
  void _handleCountdownStart(CountdownModel countdown) {
    // Mevcut alarmı iptal et
    _alarmService.cancelAlarm();
    
    _countdownService.startCountdown(countdown);
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CountdownFullscreen(
            countdown: countdown,
            countdownService: _countdownService,
            alarmService: _alarmService,
          ),
        ),
      );
    }
  }

  /// Geri sayım dairesine tıklandığında çağrılır.
  /// Ana sayfada aktif geri sayım olmadığı için bu fonksiyon çağrılmaz.
  void _handleCountdownTap() {
    // Ana sayfada aktif geri sayım yok
  }

  void _handleAlarmSet(AlarmModel alarm) {
    // Mevcut geri sayımı iptal et
    _countdownService.stopCountdown();
    
    _alarmService.setAlarm(alarm);
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AlarmFullscreen(
            alarm: alarm,
            alarmService: _alarmService,
          ),
        ),
      );
    }
  }

  /// Alarm zamanı güncellendiğinde çağrılır.
  /// Ana sayfada alarm güncellemesi yapılmaz (sadece fullscreen'de).
  void _handleAlarmUpdate(AlarmModel alarm) {
    // Ana sayfada alarm güncellemesi yapılmaz
  }

  /// Alarm dairesine tıklandığında çağrılır.
  /// Ana sayfada aktif alarm olmadığı için bu fonksiyon çağrılmaz.
  void _handleAlarmTap() {
    // Ana sayfada aktif alarm yok
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarma'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    alarmService: _alarmService,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Sistem saati (üst ortada)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Center(
                  child: SystemClock(),
                ),
              ),
              // Üst yarı - Geri Sayım
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surface,
                  child: Center(
                    child: CountdownCircle(
                      countdown: null,
                      onStart: _handleCountdownStart,
                      onTap: _handleCountdownTap,
                      hasActive: false,
                    ),
                  ),
                ),
              ),
              // Alt yarı - Alarm
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Center(
                    child: AlarmCircle(
                      alarm: null,
                      onSet: _handleAlarmSet,
                      onUpdate: _handleAlarmUpdate,
                      onTap: _handleAlarmTap,
                      hasActive: false,
                    ),
                  ),
                ),
              ),
            ],
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
    // Servisler uygulama kapanana kadar çalışacak, dispose etmeyeceğiz
    super.dispose();
  }
}

