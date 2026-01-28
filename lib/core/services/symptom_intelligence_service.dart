import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/symptom_milestones.dart';

final symptomIntelligenceServiceProvider = Provider((ref) => SymptomIntelligenceService());

class PredictedSymptom {
  final String symptomId;
  final String status;
  final String sensation;
  final String science;

  const PredictedSymptom({
    required this.symptomId,
    required this.status,
    required this.sensation,
    required this.science,
  });
}

class SymptomIntelligenceService {
  /// Returns the current active milestone for a habit based on hours elapsed.
  SymptomMilestone? getActiveMilestone(String habitId, int hoursElapsed) {
    final milestones = SymptomMilestones.habitMappings[habitId];
    if (milestones == null || milestones.isEmpty) return null;

    SymptomMilestone? current;
    for (final milestone in milestones) {
      if (hoursElapsed >= milestone.hourThreshold) {
        current = milestone;
      } else {
        break;
      }
    }
    return current;
  }

  /// Returns predicted symptoms based on the current milestone.
  List<PredictedSymptom> getPredictions(String habitId, int hoursElapsed) {
    final milestone = getActiveMilestone(habitId, hoursElapsed);
    if (milestone == null) return [];

    return [
      PredictedSymptom(
        symptomId: milestone.id,
        status: milestone.status,
        sensation: milestone.sensation,
        science: milestone.science,
      ),
    ];
  }
}
