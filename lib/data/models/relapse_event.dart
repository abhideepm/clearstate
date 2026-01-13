import 'package:hive/hive.dart';

part 'relapse_event.g.dart';

@HiveType(typeId: 2)
class RelapseEvent extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  int drinksConsumed;

  @HiveField(3)
  double costIncurred;

  @HiveField(4)
  int caloriesConsumed;

  @HiveField(5)
  int streakDaysLost;

  @HiveField(6)
  String drinkType;

  /// Whether this was a momentary slip (true) or a full relapse (false).
  /// Slips do NOT reset the sobriety timer - they only mark the day on heatmap.
  @HiveField(7)
  bool isSlip;

  RelapseEvent({
    required this.id,
    required this.timestamp,
    required this.drinksConsumed,
    required this.costIncurred,
    required this.caloriesConsumed,
    required this.streakDaysLost,
    required this.drinkType,
    this.isSlip = false,
  });
}
