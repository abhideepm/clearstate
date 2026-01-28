import 'package:flutter_test/flutter_test.dart';
import 'package:clearstate/core/services/symptom_intelligence_service.dart';

void main() {
  final service = SymptomIntelligenceService();

  group('SymptomIntelligenceService Tests', () {
    test('Returns GABA Storm milestone for alcohol at 24 hours', () {
      final milestone = service.getActiveMilestone('alcohol', 24);
      expect(milestone, isNotNull);
      expect(milestone!.status, 'GABA/Glutamate Storm');
      expect(milestone.hourThreshold, 24);
    });

    test('Returns Hour Zero milestone for alcohol at 5 hours', () {
      final milestone = service.getActiveMilestone('alcohol', 5);
      expect(milestone, isNotNull);
      expect(milestone!.status, 'Metabolic Initiation');
    });

    test('Returns Flatline for NoFap at 14 days', () {
      final hours = 14 * 24;
      final milestone = service.getActiveMilestone('nofap', hours);
      expect(milestone, isNotNull);
      expect(milestone!.status, 'Dopamine D2 Healing');
      expect(milestone.sensation, contains('Flatline'));
    });

    test('Returns empty predictions for unknown habit', () {
      final predictions = service.getPredictions('unknown', 10);
      expect(predictions, isEmpty);
    });
  });
}
