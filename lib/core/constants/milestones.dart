class RecoveryMilestone {
  final int dayThreshold;
  final String title;
  final String status;
  final String description;
  final String notificationBody;

  const RecoveryMilestone({
    required this.dayThreshold,
    required this.title,
    required this.status,
    required this.description,
    required this.notificationBody,
  });
}

class RecoveryMilestones {
  static const List<RecoveryMilestone> milestones = [
    RecoveryMilestone(
      dayThreshold: 0,
      title: 'Hour Zero',
      status: 'Beginning Recovery',
      description:
          'Your body begins processing the last alcohol consumed. Blood alcohol levels start dropping.',
      notificationBody: 'Every journey begins with a single step.',
    ),
    RecoveryMilestone(
      dayThreshold: 1,
      title: '24 Hours',
      status: 'Blood Sugar Normalizing',
      description:
          'Blood sugar levels begin to stabilize. Anxiety and irritability may peak as your body adjusts.',
      notificationBody: 'One day down. Keep going!',
    ),
    RecoveryMilestone(
      dayThreshold: 2,
      title: '48 Hours',
      status: 'Detox Progressing',
      description:
          'Alcohol has been fully metabolized. Withdrawal symptoms may be at their most intense.',
      notificationBody: 'Two days sober. Your body is healing.',
    ),
    RecoveryMilestone(
      dayThreshold: 3,
      title: '72 Hours',
      status: 'Acute Withdrawal Passing',
      description:
          'The most dangerous withdrawal period is ending. Your body is beginning to heal.',
      notificationBody: 'Three days strong. The hardest part is passing.',
    ),
    RecoveryMilestone(
      dayThreshold: 7,
      title: '1 Week',
      status: 'Sleep Patterns Improving',
      description:
          'REM sleep begins to normalize. You may start feeling more rested and mentally clear.',
      notificationBody: 'One week sober! Sleep and clarity are improving.',
    ),
    RecoveryMilestone(
      dayThreshold: 14,
      title: '2 Weeks',
      status: 'Reduced Anxiety',
      description:
          'Anxiety and depression symptoms typically decrease. Stomach lining begins to heal.',
      notificationBody: 'Two weeks! Anxiety is decreasing, energy increasing.',
    ),
    RecoveryMilestone(
      dayThreshold: 21,
      title: '3 Weeks',
      status: 'Cognitive Clarity',
      description:
          'Brain fog lifts significantly. Memory and concentration improve.',
      notificationBody: 'Three weeks! Your mind is getting sharper.',
    ),
    RecoveryMilestone(
      dayThreshold: 30,
      title: '1 Month',
      status: 'Liver Fat Reducing',
      description:
          'Liver fat can reduce by up to 15%. Blood pressure begins normalizing.',
      notificationBody: '30 days sober! Your body is healing visibly.',
    ),
    RecoveryMilestone(
      dayThreshold: 60,
      title: '2 Months',
      status: 'Immune System Strengthening',
      description:
          'Your immune system is significantly stronger. Skin health improves noticeably.',
      notificationBody: '60 days! Immune system and skin health improving.',
    ),
    RecoveryMilestone(
      dayThreshold: 90,
      title: '3 Months',
      status: 'Liver Healing',
      description:
          'Significant liver regeneration. Cardiovascular health markedly improved.',
      notificationBody: '90 days! Major healing milestone reached.',
    ),
    RecoveryMilestone(
      dayThreshold: 180,
      title: '6 Months',
      status: 'Brain Volume Restoring',
      description:
          'Brain gray matter begins to regenerate. Emotional regulation improves significantly.',
      notificationBody: 'Half a year! Brain healing is well underway.',
    ),
    RecoveryMilestone(
      dayThreshold: 365,
      title: '1 Year',
      status: 'Full Recovery Mode',
      description:
          'Risk of heart disease, stroke, and many cancers significantly reduced. Your body has undergone remarkable healing.',
      notificationBody: 'One year! A transformed life. Congratulations!',
    ),
  ];

  static RecoveryMilestone getCurrentMilestone(int days) {
    RecoveryMilestone current = milestones.first;
    for (final milestone in milestones) {
      if (days >= milestone.dayThreshold) {
        current = milestone;
      } else {
        break;
      }
    }
    return current;
  }

  static RecoveryMilestone? getNextMilestone(int days) {
    for (final milestone in milestones) {
      if (days < milestone.dayThreshold) {
        return milestone;
      }
    }
    return null;
  }

  static double getProgressToNextMilestone(int days) {
    final current = getCurrentMilestone(days);
    final next = getNextMilestone(days);

    if (next == null) return 1.0;

    final totalDays = next.dayThreshold - current.dayThreshold;
    final progressDays = days - current.dayThreshold;

    return progressDays / totalDays;
  }
}
