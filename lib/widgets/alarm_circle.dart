import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import 'time_picker_wheel.dart';

class AlarmCircle extends StatefulWidget {
  final AlarmModel? alarm;
  final Function(AlarmModel) onSet;
  final Function(AlarmModel)? onUpdate;
  final Function() onTap;
  final bool hasActive;

  const AlarmCircle({
    super.key,
    this.alarm,
    required this.onSet,
    this.onUpdate,
    required this.onTap,
    this.hasActive = false,
  });

  @override
  State<AlarmCircle> createState() => _AlarmCircleState();
}

class _AlarmCircleState extends State<AlarmCircle> {
  int _hour = 0;
  int _minute = 0;

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _hour = widget.alarm!.hour;
      _minute = widget.alarm!.minute;
    } else {
      final now = DateTime.now();
      _hour = now.hour;
      _minute = now.minute;
    }
  }
  
  @override
  void didUpdateWidget(AlarmCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alarm != null) {
      if (oldWidget.alarm == null) {
        _hour = widget.alarm!.hour;
        _minute = widget.alarm!.minute;
      } else {
        final oldHour = oldWidget.alarm!.hour;
        final oldMinute = oldWidget.alarm!.minute;
        
        if (widget.alarm!.hour != oldHour ||
            widget.alarm!.minute != oldMinute) {
          _hour = widget.alarm!.hour;
          _minute = widget.alarm!.minute;
        }
      }
    } else if (oldWidget.alarm != null && widget.alarm == null) {
      final now = DateTime.now();
      if (_hour != now.hour || _minute != now.minute) {
        _hour = now.hour;
        _minute = now.minute;
      }
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
          final alarm = AlarmModel(
            hour: _hour,
            minute: _minute,
          );
          widget.onSet(alarm);
        }
      },
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
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
                    value: _hour,
                    min: 0,
                    max: 23,
                    label: 'Saat',
                    onChanged: (value) {
                      if (_hour == value) return;
                      setState(() {
                        _hour = value;
                      });
                      if (widget.hasActive && widget.onUpdate != null) {
                        final alarm = AlarmModel(
                          hour: _hour,
                          minute: _minute,
                        );
                        widget.onUpdate!(alarm);
                      }
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
                    value: _minute,
                    min: 0,
                    max: 59,
                    label: 'Dakika',
                    onChanged: (value) {
                      if (_minute == value) return;
                      setState(() {
                        _minute = value;
                      });
                      if (widget.hasActive && widget.onUpdate != null) {
                        final alarm = AlarmModel(
                          hour: _hour,
                          minute: _minute,
                        );
                        widget.onUpdate!(alarm);
                      }
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

