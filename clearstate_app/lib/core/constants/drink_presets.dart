class DrinkPreset {
  final String name;
  final int defaultCalories;
  final double defaultCost;
  final String icon;

  const DrinkPreset({
    required this.name,
    required this.defaultCalories,
    required this.defaultCost,
    required this.icon,
  });
}

class DrinkPresets {
  static const List<DrinkPreset> presets = [
    DrinkPreset(
      name: 'Beer',
      defaultCalories: 150,
      defaultCost: 7.0,
      icon: '🍺',
    ),
    DrinkPreset(
      name: 'Wine',
      defaultCalories: 125,
      defaultCost: 10.0,
      icon: '🍷',
    ),
    DrinkPreset(
      name: 'Whiskey',
      defaultCalories: 105,
      defaultCost: 12.0,
      icon: '🥃',
    ),
    DrinkPreset(
      name: 'Vodka',
      defaultCalories: 97,
      defaultCost: 10.0,
      icon: '🍸',
    ),
    DrinkPreset(
      name: 'Cocktail',
      defaultCalories: 200,
      defaultCost: 14.0,
      icon: '🍹',
    ),
    DrinkPreset(
      name: 'Tequila',
      defaultCalories: 104,
      defaultCost: 11.0,
      icon: '🌵',
    ),
    DrinkPreset(
      name: 'Other',
      defaultCalories: 150,
      defaultCost: 8.0,
      icon: '🍾',
    ),
  ];

  static DrinkPreset getByName(String name) {
    return presets.firstWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
      orElse: () => presets.last,
    );
  }
}
