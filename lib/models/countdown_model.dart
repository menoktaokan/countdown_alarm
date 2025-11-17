class CountdownModel {
  final int hours;
  final int minutes;
  final int seconds;
  final String id;
  final DateTime? startTime;
  final bool isPaused;
  final Duration? remainingTime;

  CountdownModel({
    required this.hours,
    required this.minutes,
    required this.seconds,
    String? id,
    this.startTime,
    this.isPaused = false,
    this.remainingTime,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Duration get totalDuration {
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  CountdownModel copyWith({
    int? hours,
    int? minutes,
    int? seconds,
    String? id,
    DateTime? startTime,
    bool? isPaused,
    Duration? remainingTime,
  }) {
    return CountdownModel(
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      isPaused: isPaused ?? this.isPaused,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'id': id,
    };
  }

  factory CountdownModel.fromJson(Map<String, dynamic> json) {
    return CountdownModel(
      hours: json['hours'] as int,
      minutes: json['minutes'] as int,
      seconds: json['seconds'] as int,
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }
}

