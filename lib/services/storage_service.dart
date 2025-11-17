import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _defaultAlarmAlertTypeKey = 'default_alarm_alert_type';

  /// Varsayılan alarm uyarı tipini kaydeder.
  Future<void> saveDefaultAlarmAlertType(int alertTypeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultAlarmAlertTypeKey, alertTypeIndex);
  }

  /// Kaydedilmiş varsayılan alarm uyarı tipini yükler.
  /// Eğer kayıt yoksa 0 (single) döner.
  Future<int> loadDefaultAlarmAlertType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_defaultAlarmAlertTypeKey) ?? 0;
  }
}

