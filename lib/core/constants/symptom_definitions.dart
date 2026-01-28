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
    Symptom(id: 'tremors', displayName: 'Tremors', icon: Icons.Waves, category: SymptomCategory.physical),
    Symptom(id: 'nausea', displayName: 'Nausea', icon: Icons.Sick, category: SymptomCategory.physical),
    Symptom(id: 'sweating', displayName: 'Night Sweats', icon: Icons.WaterDrop, category: SymptomCategory.physical),
    Symptom(id: 'headache', displayName: 'Headache', icon: Icons.Headset_off, category: SymptomCategory.physical),
    Symptom(id: 'fatigue', displayName: 'Fatigue', icon: Icons.Battery_0_bar, category: SymptomCategory.physical),
    Symptom(id: 'appetite', displayName: 'Appetite Changes', icon: Icons.Restaurant, category: SymptomCategory.physical),

    // Emotional
    Symptom(id: 'anxiety', displayName: 'Anxiety', icon: Icons.Air, category: SymptomCategory.emotional),
    Symptom(id: 'irritability', displayName: 'Irritability', icon: Icons.Whatshot, category: SymptomCategory.emotional),
    Symptom(id: 'depression', displayName: 'Low Mood', icon: Icons.Cloud, category: SymptomCategory.emotional),
    Symptom(id: 'anhedonia', displayName: 'Flatness', icon: Icons.Desktop_access_disabled, category: SymptomCategory.emotional),

    // Cognitive
    Symptom(id: 'brain_fog', displayName: 'Brain Fog', icon: Icons.Blur_on, category: SymptomCategory.cognitive),
    Symptom(id: 'concentration', displayName: 'Difficulty Concentrating', icon: Icons.Filter_center_focus, category: SymptomCategory.cognitive),

    // Sleep
    Symptom(id: 'insomnia', displayName: 'Insomnia', icon: Icons.Bedtime_off, category: SymptomCategory.sleep),
    Symptom(id: 'vivid_dreams', displayName: 'Vivid Dreams', icon: Icons.Auto_awesome, category: SymptomCategory.sleep),

    // Cravings
    Symptom(id: 'craving_intense', displayName: 'Intense Craving', icon: Icons.Bolt, category: SymptomCategory.cravings),
    Symptom(id: 'sugar_craving', displayName: 'Sugar Cravings', icon: Icons.Icecream, category: SymptomCategory.cravings),
  ];
}
