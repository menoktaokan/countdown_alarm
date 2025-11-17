import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import '../services/audio_service.dart';
import '../utils/time_formatter.dart';
import '../widgets/system_clock.dart';
import '../widgets/alarm_indicator.dart';

class AlarmFullscreen extends StatefulWidget {
  final AlarmModel alarm;
  final AlarmService alarmService;

  const AlarmFullscreen({
    super.key,
    required this.alarm,
    required this.alarmService,
  });

  @override
  State<AlarmFullscreen> createState() => _AlarmFullscreenState();
}

class _AlarmFullscreenState extends State<AlarmFullscreen> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  bool _isAlarmPlaying = false;
  late final Function(bool) _alarmPlayingListener;

  @override
  void initState() {
    super.initState();
    // Doğrudan AudioService'den dinle
    _isAlarmPlaying = AudioService.instance.isPlaying;
    
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _blinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
    
    _blinkController.repeat(reverse: true);
    
    _alarmPlayingListener = (bool isPlaying) {
      if (mounted) {
        setState(() {
          _isAlarmPlaying = isPlaying;
        });
      }
    };
    AudioService.instance.addPlayingListener(_alarmPlayingListener);
  }
  
  @override
  void dispose() {
    AudioService.instance.removePlayingListener(_alarmPlayingListener);
    _blinkController.dispose();
    super.dispose();
  }

  /// Geri butonuna tıklandığında çağrılır.
  /// Alarmı iptal eder ve ana ekrana döner.
  void _handleBack() {
    widget.alarmService.cancelAlarm();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Stack(
        children: [
          Container(
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
              // Alarm saati
              AnimatedBuilder(
                animation: _blinkAnimation,
                builder: (context, child) {
                  final timeString = TimeFormatter.formatAlarm(widget.alarm.hour, widget.alarm.minute);
                  // ":" ifadesini yanıp sönen hale getir
                  final parts = timeString.split(':');
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        parts[0],
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                      ),
                      Opacity(
                        opacity: _blinkAnimation.value,
                        child: Text(
                          ':',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                        ),
                      ),
                      Text(
                        parts[1],
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 60),
              // Geri butonu
              IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 32,
                onPressed: _handleBack,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
                ],
              ),
            ),
          // Alarm çalma göstergesi (sağ altta)
          if (_isAlarmPlaying) const AlarmIndicator(),
        ],
      ),
    );
  }
}

