import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/time_formatter.dart';

/// Sistem saatini gösteren widget.
/// Her saniye otomatik güncellenir.
class SystemClock extends StatefulWidget {
  const SystemClock({super.key});

  @override
  State<SystemClock> createState() => _SystemClockState();
}

class _SystemClockState extends State<SystemClock> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  void _startClock() {
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      TimeFormatter.formatAlarm(_currentTime.hour, _currentTime.minute) +
          ':${_currentTime.second.toString().padLeft(2, '0')}',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }
}

