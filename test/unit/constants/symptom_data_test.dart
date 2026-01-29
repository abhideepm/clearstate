import 'package:flutter_test/flutter_test.dart';
import 'package:truestate/core/constants/symptom_definitions.dart';
import 'package:truestate/core/constants/symptom_milestones.dart';

void main() {
  group('Symptom Data Tests', () {
    test('Symptom master list is populated', () {
      expect(SymptomDefinitions.all.isNotEmpty, true);
      expect(SymptomDefinitions.all.any((s) => s.id == 'tremors'), true);
    });

    test('Alcohol milestones are mapped correctly', () {
      final alcohol = SymptomMilestones.habitMappings['alcohol'];
      expect(alcohol, isNotNull);
      expect(alcohol!.any((m) => m.hourThreshold == 24), true);
      expect(alcohol.firstWhere((m) => m.hourThreshold == 24).status, 'GABA/Glutamate Storm');
    });

    test('NoFap milestones include the Flatline', () {
      final nofap = SymptomMilestones.habitMappings['nofap'];
      expect(nofap, isNotNull);
      expect(nofap!.any((m) => m.id == 'nf_336'), true);
      expect(nofap.firstWhere((m) => m.id == 'nf_336').sensation, contains('Flatline'));
    });
  });
}
