import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  bool onboardingComplete;

  @HiveField(1)
  List<String> selectedHabitIds;

  @HiveField(2)
  DateTime? lastDrinkDate;

  @HiveField(3)
  double avgDailySpend;

  @HiveField(4)
  int avgDailyCalories;

  @HiveField(5)
  int avgDrinksPerWeek;

  UserProfile({
    this.onboardingComplete = false,
    this.selectedHabitIds = const [],
    this.lastDrinkDate,
    this.avgDailySpend = 0,
    this.avgDailyCalories = 0,
    this.avgDrinksPerWeek = 0,
  });

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'onboardingComplete': onboardingComplete,
      'selectedHabitIds': selectedHabitIds,
      'lastDrinkDate': (lastDrinkDate ?? DateTime.now()).toIso8601String(),
      'avgDailySpend': avgDailySpend,
      'avgDailyCalories': avgDailyCalories,
      'avgDrinksPerWeek': avgDrinksPerWeek,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      selectedHabitIds:
          (json['selectedHabitIds'] as List?)?.cast<String>() ?? [],
      lastDrinkDate: json['lastDrinkDate'] != null
          ? DateTime.tryParse(json['lastDrinkDate'] as String)
          : null,
      avgDailySpend: (json['avgDailySpend'] as num?)?.toDouble() ?? 0,
      avgDailyCalories: (json['avgDailyCalories'] as num?)?.toInt() ?? 0,
      avgDrinksPerWeek: (json['avgDrinksPerWeek'] as num?)?.toInt() ?? 0,
    );
  }
}
