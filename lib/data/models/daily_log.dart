import 'package:hive/hive.dart';

part 'daily_log.g.dart';

@HiveType(typeId: 3)
class DailyLog extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  bool isSober;

  @HiveField(2)
  int? drinksConsumed; // null if sober

  DailyLog({required this.date, required this.isSober, this.drinksConsumed});

  // Get date as YYYY-MM-DD string for heatmap key
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'isSober': isSober,
      'drinksConsumed': drinksConsumed,
    };
  }

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      date: DateTime.parse(json['date'] as String),
      isSober: json['isSober'] as bool,
      drinksConsumed: json['drinksConsumed'] as int?,
    );
  }
}
