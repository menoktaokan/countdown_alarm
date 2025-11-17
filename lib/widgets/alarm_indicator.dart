import 'package:flutter/material.dart';

/// Alarm çaldığını gösteren simge widget'ı.
/// Sağ altta kırmızı yuvarlak alarm ikonu gösterir.
class AlarmIndicator extends StatelessWidget {
  const AlarmIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.error.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(
          Icons.alarm,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

