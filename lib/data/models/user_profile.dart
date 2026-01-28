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

  @HiveField(6)
  DateTime? trialStartDate;

  @HiveField(7)
  bool isPremium;

  UserProfile({
    this.onboardingComplete = false,
    this.selectedHabitIds = const [],
    this.lastDrinkDate,
    this.trialStartDate,
    this.isPremium = false,
  });

  /// Check if user is in trial period (14 days)
  bool get isInTrial {
    if (isPremium) return false;
    if (trialStartDate == null) return false;
    
    final trialEnd = trialStartDate!.add(const Duration(days: 14));
    return DateTime.now().isBefore(trialEnd);
  }

  /// Check if trial has expired
  bool get isTrialExpired {
    if (isPremium) return false;
    if (trialStartDate == null) return false;
    
    final trialEnd = trialStartDate!.add(const Duration(days: 14));
    return DateTime.now().isAfter(trialEnd);
  }

  /// Days remaining in trial
  int get trialDaysRemaining {
    if (isPremium || trialStartDate == null) return 0;
    
    final trialEnd = trialStartDate!.add(const Duration(days: 14));
    final remaining = trialEnd.difference(DateTime.now()).inDays;
    return remaining.clamp(0, 14);
  }

  /// Whether user has premium access (either paid or trial)
  bool get hasPremiumAccess => isPremium || isInTrial;

  Map<String, dynamic> toJson() {
    return {
      'onboardingComplete': onboardingComplete,
      'selectedHabitIds': selectedHabitIds,
      'lastDrinkDate': lastDrinkDate?.toIso8601String(),
      'trialStartDate': trialStartDate?.toIso8601String(),
      'isPremium': isPremium,
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
      trialStartDate: json['trialStartDate'] != null
          ? DateTime.tryParse(json['trialStartDate'] as String)
          : null,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }
}
