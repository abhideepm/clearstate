import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 5)
enum HabitType {
  @HiveField(0)
  substance,
  @HiveField(1)
  behavioral,
}

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final HabitType type;

  @HiveField(3)
  final String themeColor; // Neon hex

  @HiveField(4)
  final String motivation;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  DateTime? endDate; // null = currently active

  Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.themeColor,
    required this.motivation,
    required this.startDate,
    this.endDate,
  });

  bool get isActive => endDate == null;

  Duration get elapsed {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate);
  }

  int get totalDays => elapsed.inDays;

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'themeColor': themeColor,
      'motivation': motivation,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      type: HabitType.values.byName(json['type'] as String),
      themeColor: json['themeColor'] as String,
      motivation: json['motivation'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }
}
