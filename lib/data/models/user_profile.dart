import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  DateTime lastDrinkDate;

  @HiveField(1)
  int avgDrinksPerWeek;

  @HiveField(2)
  double avgCostPerDrink;

  @HiveField(3)
  int avgCaloriesPerDrink;

  @HiveField(4)
  String defaultDrinkType;

  @HiveField(5)
  bool onboardingComplete;

  @HiveField(6, defaultValue: 'USD')
  String currency;

  UserProfile({
    required this.lastDrinkDate,
    this.avgDrinksPerWeek = 10,
    this.avgCostPerDrink = 8.0,
    this.avgCaloriesPerDrink = 150,
    this.defaultDrinkType = 'Beer',
    this.onboardingComplete = false,
    this.currency = 'USD',
  });

  // Calculate average daily spend
  double get avgDailySpend => (avgDrinksPerWeek * avgCostPerDrink) / 7;

  // Calculate average daily calories
  double get avgDailyCalories => (avgDrinksPerWeek * avgCaloriesPerDrink) / 7;

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'lastDrinkDate': lastDrinkDate.toIso8601String(),
      'avgDrinksPerWeek': avgDrinksPerWeek,
      'avgCostPerDrink': avgCostPerDrink,
      'avgCaloriesPerDrink': avgCaloriesPerDrink,
      'defaultDrinkType': defaultDrinkType,
      'onboardingComplete': onboardingComplete,
      'currency': currency,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      lastDrinkDate: DateTime.parse(json['lastDrinkDate'] as String),
      avgDrinksPerWeek: json['avgDrinksPerWeek'] as int,
      avgCostPerDrink: (json['avgCostPerDrink'] as num).toDouble(),
      avgCaloriesPerDrink: json['avgCaloriesPerDrink'] as int,
      defaultDrinkType: json['defaultDrinkType'] as String,
      onboardingComplete: json['onboardingComplete'] as bool,
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}
