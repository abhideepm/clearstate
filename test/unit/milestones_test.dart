import 'package:flutter_test/flutter_test.dart';
import 'package:clearstate/core/constants/milestones.dart';

void main() {
  group('RecoveryMilestones', () {
    test('getCurrentMilestone returns correct milestone based on days', () {
      expect(RecoveryMilestones.getCurrentMilestone(0).title, 'Hour Zero');
      expect(RecoveryMilestones.getCurrentMilestone(1).title, '24 Hours');
      expect(RecoveryMilestones.getCurrentMilestone(5).title, '72 Hours');
      expect(RecoveryMilestones.getCurrentMilestone(10).title, '1 Week');
      expect(RecoveryMilestones.getCurrentMilestone(400).title, '1 Year');
    });

    test('getNextMilestone returns next milestone correctly', () {
      expect(RecoveryMilestones.getNextMilestone(0)?.title, '24 Hours');
      expect(RecoveryMilestones.getNextMilestone(1)?.title, '48 Hours');
      expect(RecoveryMilestones.getNextMilestone(365), isNull);
    });

    test('getProgressToNextMilestone calculates percentage correctly', () {
      // Halfway between 0 and 1 day
      expect(RecoveryMilestones.getProgressToNextMilestone(0), 0.0);

      // Halfway between 7 days and 14 days (1 week and 2 weeks)
      // Current: 7, Next: 14. Total: 7 days. Progress: 3.5 days.
      // days = 10.5
      expect(
        RecoveryMilestones.getProgressToNextMilestone(10),
        closeTo(0.42, 0.01),
      );

      // Beyond all milestones
      expect(RecoveryMilestones.getProgressToNextMilestone(400), 1.0);
    });
  });
}
