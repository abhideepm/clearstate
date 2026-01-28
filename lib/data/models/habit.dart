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
  final String themeColor;

  @HiveField(4)
  final String motivation;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  DateTime? endDate;

  @HiveField(7)
  final int longestStreak;

  @HiveField(8)
  final int relapseCount;

  @HiveField(9)
  final int totalSoberDays;

  Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.themeColor,
    required this.motivation,
    required this.startDate,
    this.endDate,
    this.longestStreak = 0,
    this.relapseCount = 0,
    this.totalSoberDays = 0,
  });

  bool get isActive => endDate == null;

  Duration get elapsed {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate);
  }

  int get totalDays => elapsed.inDays;

  int get currentStreak => totalDays;

  /// Create a copy with updated fields
  Habit copyWith({
    String? id,
    String? name,
    HabitType? type,
    String? themeColor,
    String? motivation,
    DateTime? startDate,
    DateTime? endDate,
    int? longestStreak,
    int? relapseCount,
    int? totalSoberDays,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      themeColor: themeColor ?? this.themeColor,
      motivation: motivation ?? this.motivation,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      longestStreak: longestStreak ?? this.longestStreak,
      relapseCount: relapseCount ?? this.relapseCount,
      totalSoberDays: totalSoberDays ?? this.totalSoberDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'themeColor': themeColor,
      'motivation': motivation,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'longestStreak': longestStreak,
      'relapseCount': relapseCount,
      'totalSoberDays': totalSoberDays,
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
      longestStreak: json['longestStreak'] as int? ?? 0,
      relapseCount: json['relapseCount'] as int? ?? 0,
      totalSoberDays: json['totalSoberDays'] as int? ?? 0,
    );
  }
}
