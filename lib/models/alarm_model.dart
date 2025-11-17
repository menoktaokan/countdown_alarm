class AlarmModel {
  final int hour;
  final int minute;
  final String id;
  final bool isActive;
  final bool isPaused;

  AlarmModel({
    required this.hour,
    required this.minute,
    String? id,
    this.isActive = false,
    this.isPaused = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  AlarmModel copyWith({
    int? hour,
    int? minute,
    String? id,
    bool? isActive,
    bool? isPaused,
  }) {
    return AlarmModel(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      id: id ?? this.id,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
      'id': id,
      'isActive': isActive,
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  DateTime getNextAlarmTime() {
    final now = DateTime.now();
    var alarmTime = DateTime(now.year, now.month, now.day, hour, minute);

    // Eğer alarm saati geçmişse, yarın için ayarla
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    return alarmTime;
  }
}

