import 'package:flutter/material.dart';
import '../models/countdown_model.dart';
import 'time_picker_wheel.dart';

class CountdownCircle extends StatefulWidget {
  final CountdownModel? countdown;
  final Function(CountdownModel) onStart;
  final Function() onTap;
  final bool hasActive;

  const CountdownCircle({
    super.key,
    this.countdown,
    required this.onStart,
    required this.onTap,
    this.hasActive = false,
  });

  @override
  State<CountdownCircle> createState() => _CountdownCircleState();
}

class _CountdownCircleState extends State<CountdownCircle> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.countdown != null) {
      _hours = widget.countdown!.hours;
      _minutes = widget.countdown!.minutes;
      _seconds = widget.countdown!.seconds;
    }
  }

  @override
  void didUpdateWidget(CountdownCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.countdown != null) {
      final oldHours = oldWidget.countdown?.hours ?? 0;
      final oldMinutes = oldWidget.countdown?.minutes ?? 0;
      final oldSeconds = oldWidget.countdown?.seconds ?? 0;
      
      if (widget.countdown!.hours != oldHours ||
          widget.countdown!.minutes != oldMinutes ||
          widget.countdown!.seconds != oldSeconds) {
        _hours = widget.countdown!.hours;
        _minutes = widget.countdown!.minutes;
        _seconds = widget.countdown!.seconds;
      }
    } else if (oldWidget.countdown != null) {
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = size.width * 0.7;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (widget.hasActive) {
          widget.onTap();
        } else {
          if (_hours == 0 && _minutes == 0 && _seconds == 0) {
            return;
          }
          final countdown = CountdownModel(
            hours: _hours,
            minutes: _minutes,
            seconds: _seconds,
          );
          widget.onStart(countdown);
        }
      },
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TimePickerWheel(
                    value: _hours,
                    min: 0,
                    max: 23,
                    label: 'Saat',
                    onChanged: (value) {
                      setState(() {
                        _hours = value;
                      });
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      ':',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TimePickerWheel(
                    value: _minutes,
                    min: 0,
                    max: 59,
                    label: 'Dakika',
                    onChanged: (value) {
                      setState(() {
                        _minutes = value;
                      });
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      ':',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TimePickerWheel(
                    value: _seconds,
                    min: 0,
                    max: 59,
                    label: 'Saniye',
                    onChanged: (value) {
                      setState(() {
                        _seconds = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

