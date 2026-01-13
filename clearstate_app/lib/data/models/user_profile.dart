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

  UserProfile({
    required this.lastDrinkDate,
    this.avgDrinksPerWeek = 10,
    this.avgCostPerDrink = 8.0,
    this.avgCaloriesPerDrink = 150,
    this.defaultDrinkType = 'Beer',
    this.onboardingComplete = false,
  });

  // Calculate average daily spend
  double get avgDailySpend => (avgDrinksPerWeek * avgCostPerDrink) / 7;

  // Calculate average daily calories
  double get avgDailyCalories => (avgDrinksPerWeek * avgCaloriesPerDrink) / 7;
}
