import 'package:flutter/material.dart';

enum SymptomCategory { physical, emotional, cognitive, sleep, cravings }

class Symptom {
  final String id;
  final String displayName;
  final IconData icon;
  final SymptomCategory category;

  const Symptom({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.category,
  });
}

class SymptomDefinitions {
  static const List<Symptom> all = [
    // Physical
    Symptom(
      id: 'tremors',
      displayName: 'Tremors',
      icon: Icons.waves,
      category: SymptomCategory.physical,
    ),
    Symptom(
      id: 'nausea',
      displayName: 'Nausea',
      icon: Icons.sick,
      category: SymptomCategory.physical,
    ),
    Symptom(
      id: 'sweating',
      displayName: 'Night Sweats',
      icon: Icons.water_drop,
      category: SymptomCategory.physical,
    ),
    Symptom(
      id: 'headache',
      displayName: 'Headache',
      icon: Icons.headset_off,
      category: SymptomCategory.physical,
    ),
    Symptom(
      id: 'fatigue',
      displayName: 'Fatigue',
      icon: Icons.battery_0_bar,
      category: SymptomCategory.physical,
    ),
    Symptom(
      id: 'appetite',
      displayName: 'Appetite Changes',
      icon: Icons.restaurant,
      category: SymptomCategory.physical,
    ),

    // Emotional
    Symptom(
      id: 'anxiety',
      displayName: 'Anxiety',
      icon: Icons.air,
      category: SymptomCategory.emotional,
    ),
    Symptom(
      id: 'irritability',
      displayName: 'Irritability',
      icon: Icons.whatshot,
      category: SymptomCategory.emotional,
    ),
    Symptom(
      id: 'depression',
      displayName: 'Low Mood',
      icon: Icons.cloud,
      category: SymptomCategory.emotional,
    ),
    Symptom(
      id: 'anhedonia',
      displayName: 'Flatness',
      icon: Icons.desktop_access_disabled,
      category: SymptomCategory.emotional,
    ),

    // Cognitive
    Symptom(
      id: 'brain_fog',
      displayName: 'Brain Fog',
      icon: Icons.blur_on,
      category: SymptomCategory.cognitive,
    ),
    Symptom(
      id: 'concentration',
      displayName: 'Difficulty Concentrating',
      icon: Icons.filter_center_focus,
      category: SymptomCategory.cognitive,
    ),

    // Sleep
    Symptom(
      id: 'insomnia',
      displayName: 'Insomnia',
      icon: Icons.bedtime_off,
      category: SymptomCategory.sleep,
    ),
    Symptom(
      id: 'vivid_dreams',
      displayName: 'Vivid Dreams',
      icon: Icons.auto_awesome,
      category: SymptomCategory.sleep,
    ),

    // Cravings
    Symptom(
      id: 'craving_intense',
      displayName: 'Intense Craving',
      icon: Icons.bolt,
      category: SymptomCategory.cravings,
    ),
    Symptom(
      id: 'sugar_craving',
      displayName: 'Sugar Cravings',
      icon: Icons.icecream,
      category: SymptomCategory.cravings,
    ),
  ];
}
