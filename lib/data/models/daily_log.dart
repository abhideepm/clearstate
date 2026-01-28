import 'package:hive/hive.dart';

part 'daily_log.g.dart';

@HiveType(typeId: 3)
class DailyLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final int moodScore; // 1-5

  @HiveField(3)
  final List<String> symptoms;

  @HiveField(4)
  final bool isSlip; // Lapse

  @HiveField(5)
  final bool isRelapse;

  DailyLog({
    required this.date,
    required this.habitId,
    required this.moodScore,
    required this.symptoms,
    required this.isSlip,
    required this.isRelapse,
  });

  // Get date as YYYY-MM-DD string for heatmap key
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'habitId': habitId,
      'moodScore': moodScore,
      'symptoms': symptoms,
      'isSlip': isSlip,
      'isRelapse': isRelapse,
    };
  }

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      date: DateTime.parse(json['date'] as String),
      habitId: json['habitId'] as String,
      moodScore: json['moodScore'] as int,
      symptoms: (json['symptoms'] as List).cast<String>(),
      isSlip: json['isSlip'] as bool,
      isRelapse: json['isRelapse'] as bool,
    );
  }
}
