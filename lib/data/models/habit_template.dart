import 'package:flutter/material.dart';
import 'habit.dart';

/// Predefined habit templates for onboarding selection.
/// Users can select multiple habits to form their "Stack".
class HabitTemplate {
  final String id;
  final String name;
  final HabitType type;
  final IconData icon;
  final Color defaultThemeColor;
  final String description;

  const HabitTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.defaultThemeColor,
    required this.description,
  });

  /// Creates a Habit instance from this template.
  /// [startDate] - when the user started tracking this habit
  /// [motivation] - user's personal motivation for this habit
  Habit toHabit({
    required DateTime startDate,
    String motivation = '',
  }) {
    return Habit(
      id: id,
      name: name,
      type: type,
      themeColor: '#${defaultThemeColor.value.toRadixString(16).substring(2)}',
      motivation: motivation,
      startDate: startDate,
    );
  }

  /// All predefined habit templates available during onboarding.
  static const List<HabitTemplate> all = [
    alcohol,
    weed,
    caffeine,
    porn,
    nicotine,
  ];

  static const alcohol = HabitTemplate(
    id: 'alcohol',
    name: 'Alcohol',
    type: HabitType.substance,
    icon: Icons.local_bar,
    defaultThemeColor: Color(0xFFB0FF00), // acidGreen
    description: 'Beer, wine, spirits, and other alcoholic beverages',
  );

  static const weed = HabitTemplate(
    id: 'weed',
    name: 'Weed / Cannabis',
    type: HabitType.substance,
    icon: Icons.eco,
    defaultThemeColor: Color(0xFF4CAF50), // green
    description: 'Marijuana, edibles, concentrates',
  );

  static const caffeine = HabitTemplate(
    id: 'caffeine',
    name: 'Caffeine',
    type: HabitType.substance,
    icon: Icons.coffee,
    defaultThemeColor: Color(0xFF8D6E63), // brown
    description: 'Coffee, energy drinks, pre-workout',
  );

  static const porn = HabitTemplate(
    id: 'porn',
    name: 'Porn / NoFap',
    type: HabitType.behavioral,
    icon: Icons.block,
    defaultThemeColor: Color(0xFFFF5722), // deep orange
    description: 'Adult content and compulsive behaviors',
  );

  static const nicotine = HabitTemplate(
    id: 'nicotine',
    name: 'Nicotine',
    type: HabitType.substance,
    icon: Icons.smoke_free,
    defaultThemeColor: Color(0xFF607D8B), // blue grey
    description: 'Cigarettes, vapes, patches, gum',
  );

  /// Get a template by its ID.
  static HabitTemplate? byId(String id) {
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Extension to get display-friendly type labels.
extension HabitTypeLabel on HabitType {
  String get label {
    switch (this) {
      case HabitType.substance:
        return 'SUBSTANCE';
      case HabitType.behavioral:
        return 'BEHAVIORAL';
    }
  }
}
