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
}
