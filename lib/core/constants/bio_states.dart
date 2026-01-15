/// Represents a single point on a recovery curve.
class BioStatePoint {
  final int day;
  final double value;

  const BioStatePoint(this.day, this.value);
}

/// Represents a biological metric that recovers over time during sobriety.
class BioStateMetric {
  final String id;
  final String displayName;
  final String stealthLabel;
  final String description;
  final List<BioStatePoint> curve;

  const BioStateMetric({
    required this.id,
    required this.displayName,
    required this.stealthLabel,
    required this.description,
    required this.curve,
  });

  /// Interpolates the recovery value for a given day.
  /// Returns a value between 0.0 and 1.0.
  double getValueForDay(int days) {
    if (days <= 0) return curve.first.value;
    if (days >= curve.last.day) return curve.last.value;

    // Find the two points to interpolate between
    BioStatePoint lower = curve.first;
    BioStatePoint upper = curve.last;

    for (int i = 0; i < curve.length - 1; i++) {
      if (days >= curve[i].day && days < curve[i + 1].day) {
        lower = curve[i];
        upper = curve[i + 1];
        break;
      }
    }

    // Linear interpolation
    final dayRange = upper.day - lower.day;
    final valueRange = upper.value - lower.value;
    final dayProgress = days - lower.day;

    return lower.value + (valueRange * dayProgress / dayRange);
  }
}

/// Bio-state recovery curves based on neuroscience research approximations.
class BioStates {
  static const BioStateMetric gaba = BioStateMetric(
    id: 'gaba',
    displayName: 'GABA Balance',
    stealthLabel: 'Calm Index',
    description: 'Inhibitory neurotransmitter recovery',
    curve: [
      BioStatePoint(0, 0.30),
      BioStatePoint(3, 0.40),
      BioStatePoint(7, 0.55),
      BioStatePoint(14, 0.65),
      BioStatePoint(30, 0.78),
      BioStatePoint(60, 0.88),
      BioStatePoint(90, 0.94),
      BioStatePoint(180, 0.98),
      BioStatePoint(365, 1.0),
    ],
  );

  static const BioStateMetric dopamine = BioStateMetric(
    id: 'dopamine',
    displayName: 'Dopamine Sensitivity',
    stealthLabel: 'Reward Response',
    description: 'Pleasure/motivation system recovery',
    curve: [
      BioStatePoint(0, 0.40),
      BioStatePoint(3, 0.42),
      BioStatePoint(7, 0.50),
      BioStatePoint(14, 0.58),
      BioStatePoint(30, 0.70),
      BioStatePoint(60, 0.82),
      BioStatePoint(90, 0.90),
      BioStatePoint(180, 0.96),
      BioStatePoint(365, 1.0),
    ],
  );

  static const BioStateMetric serotonin = BioStateMetric(
    id: 'serotonin',
    displayName: 'Serotonin Levels',
    stealthLabel: 'Mood Balance',
    description: 'Mood regulation neurotransmitter',
    curve: [
      BioStatePoint(0, 0.35),
      BioStatePoint(3, 0.40),
      BioStatePoint(7, 0.50),
      BioStatePoint(14, 0.60),
      BioStatePoint(30, 0.72),
      BioStatePoint(60, 0.84),
      BioStatePoint(90, 0.92),
      BioStatePoint(180, 0.97),
      BioStatePoint(365, 1.0),
    ],
  );

  static const BioStateMetric sleep = BioStateMetric(
    id: 'sleep',
    displayName: 'Sleep Quality',
    stealthLabel: 'Rest Score',
    description: 'REM sleep normalization',
    curve: [
      BioStatePoint(0, 0.20),
      BioStatePoint(3, 0.35),
      BioStatePoint(7, 0.55),
      BioStatePoint(14, 0.70),
      BioStatePoint(30, 0.82),
      BioStatePoint(60, 0.90),
      BioStatePoint(90, 0.95),
      BioStatePoint(180, 0.98),
      BioStatePoint(365, 1.0),
    ],
  );

  static const BioStateMetric liver = BioStateMetric(
    id: 'liver',
    displayName: 'Liver Function',
    stealthLabel: 'Metabolic Health',
    description: 'Liver fat reduction and regeneration',
    curve: [
      BioStatePoint(0, 0.60),
      BioStatePoint(3, 0.62),
      BioStatePoint(7, 0.68),
      BioStatePoint(14, 0.75),
      BioStatePoint(30, 0.85),
      BioStatePoint(60, 0.92),
      BioStatePoint(90, 0.96),
      BioStatePoint(180, 0.99),
      BioStatePoint(365, 1.0),
    ],
  );

  static const BioStateMetric brain = BioStateMetric(
    id: 'brain',
    displayName: 'Brain Volume',
    stealthLabel: 'Cognitive Index',
    description: 'Gray matter regeneration',
    curve: [
      BioStatePoint(0, 0.70),
      BioStatePoint(3, 0.70),
      BioStatePoint(7, 0.72),
      BioStatePoint(14, 0.74),
      BioStatePoint(30, 0.78),
      BioStatePoint(60, 0.84),
      BioStatePoint(90, 0.90),
      BioStatePoint(180, 0.95),
      BioStatePoint(365, 0.99),
    ],
  );

  /// All physical metrics (excludes the computed recovery index).
  static const List<BioStateMetric> _physicalMetrics = [
    gaba,
    dopamine,
    serotonin,
    sleep,
    liver,
    brain,
  ];

  /// Returns the metric matching the given ID, or null if not found.
  static BioStateMetric? getMetric(String id) {
    if (id == 'recovery') {
      return _createRecoveryIndexMetric();
    }
    for (final metric in _physicalMetrics) {
      if (metric.id == id) {
        return metric;
      }
    }
    return null;
  }

  /// Returns all metrics including the computed recovery index.
  static List<BioStateMetric> getAllMetrics() {
    return [..._physicalMetrics, _createRecoveryIndexMetric()];
  }

  /// Calculates the combined recovery index for a given day.
  /// This is the average of all physical metrics.
  static double getRecoveryIndex(int days) {
    double sum = 0;
    for (final metric in _physicalMetrics) {
      sum += metric.getValueForDay(days);
    }
    return sum / _physicalMetrics.length;
  }

  /// Creates the recovery index metric with dynamically computed curve.
  static BioStateMetric _createRecoveryIndexMetric() {
    // Generate curve points at the same days as other metrics
    const dayPoints = [0, 3, 7, 14, 30, 60, 90, 180, 365];
    final curve = dayPoints
        .map((day) => BioStatePoint(day, getRecoveryIndex(day)))
        .toList();

    return BioStateMetric(
      id: 'recovery',
      displayName: 'Recovery Index',
      stealthLabel: 'Wellness Score',
      description: 'Combined overall recovery metric',
      curve: curve,
    );
  }
}
