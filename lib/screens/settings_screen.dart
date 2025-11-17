import 'package:flutter/material.dart';
import '../services/alarm_service.dart';
import '../models/alert_type.dart';
import '../widgets/system_clock.dart';
import '../widgets/alarm_indicator.dart';

class SettingsScreen extends StatefulWidget {
  final AlarmService alarmService;

  const SettingsScreen({
    super.key,
    required this.alarmService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAlarmPlaying = false;
  late final Function(bool) _alarmPlayingListener;

  @override
  void initState() {
    super.initState();
    _isAlarmPlaying = widget.alarmService.isAlarmPlaying;
    _alarmPlayingListener = (bool isPlaying) {
      if (mounted) {
        setState(() {
          _isAlarmPlaying = isPlaying;
        });
      }
    };
    widget.alarmService.addAlarmPlayingListener(_alarmPlayingListener);
  }

  @override
  void dispose() {
    widget.alarmService.removeAlarmPlayingListener(_alarmPlayingListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Varsayılan alarm tipini göster
    final currentAlertType = widget.alarmService.defaultAlertType;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Sistem saati (üst ortada)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Center(
                  child: SystemClock(),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_active),
                      title: const Text('Alarm Tipini Seç'),
                      subtitle: Text(
                        currentAlertType == AlertType.single 
                            ? 'Tek Bip' 
                            : 'Sürekli Bip (60 saniye)',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showAlertTypeDialog(context, currentAlertType);
                      },
                    ),
                  ],
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

  /// Alarm tipi seçim dialog'unu gösterir.
  void _showAlertTypeDialog(BuildContext context, AlertType currentType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alarm Tipini Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AlertType>(
              title: const Text('Tek Bip'),
              subtitle: const Text('Alarm çaldığında tek bir bip sesi'),
              value: AlertType.single,
              groupValue: currentType,
              onChanged: (value) {
                if (value != null) {
                  _updateAlertType(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<AlertType>(
              title: const Text('Sürekli Bip'),
              subtitle: const Text('60 saniye boyunca tekrarlayan bip sesi'),
              value: AlertType.continuous,
              groupValue: currentType,
              onChanged: (value) {
                if (value != null) {
                  _updateAlertType(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Alarm tipini günceller.
  void _updateAlertType(AlertType alertType) async {
    await widget.alarmService.updateDefaultAlertType(alertType);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alertType == AlertType.single 
              ? 'Alarm tipi: Tek Bip' 
              : 'Alarm tipi: Sürekli Bip',
        ),
      ),
    );
  }
}

