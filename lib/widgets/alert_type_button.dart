import 'package:flutter/material.dart';
import '../models/alert_type.dart';

class AlertTypeButton extends StatelessWidget {
  final AlertType alertType;
  final ValueChanged<AlertType> onChanged;

  const AlertTypeButton({
    super.key,
    required this.alertType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final newType = alertType == AlertType.single
            ? AlertType.continuous
            : AlertType.single;
        onChanged(newType);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: alertType == AlertType.single
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            alertType == AlertType.single
                ? Icons.notifications_active
                : Icons.notifications,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

