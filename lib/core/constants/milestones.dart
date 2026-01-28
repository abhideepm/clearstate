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
  /// Get milestones for a specific habit
  static List<RecoveryMilestone> getMilestonesForHabit(String habitId) {
    switch (habitId) {
      case 'alcohol':
        return alcoholMilestones;
      case 'nicotine':
        return nicotineMilestones;
      case 'porn':
        return pornMilestones;
      case 'caffeine':
        return caffeineMilestones;
      case 'weed':
        return weedMilestones;
      default:
        return genericMilestones;
    }
  }

  static RecoveryMilestone getCurrentMilestoneFromList(
    int days,
    List<RecoveryMilestone> milestones,
  ) {
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

  // Legacy method for backward compatibility
  static RecoveryMilestone getCurrentMilestone(int days) {
    return getCurrentMilestoneFromList(days, milestones);
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
    
    final total = next.dayThreshold - current.dayThreshold;
    if (total <= 0) return 1.0;
    
    final progress = (days - current.dayThreshold) / total;
    return progress.clamp(0.0, 1.0);
  }

  // Legacy alias
  static const List<RecoveryMilestone> milestones = alcoholMilestones;

  // ============ ALCOHOL MILESTONES ============
  static const List<RecoveryMilestone> alcoholMilestones = [
    RecoveryMilestone(
      dayThreshold: 0,
      title: 'Hour Zero',
      status: 'Beginning Recovery',
      description: 'Your body begins processing alcohol. Blood alcohol levels start dropping.',
      notificationBody: 'Every journey begins with a single step.',
    ),
    RecoveryMilestone(
      dayThreshold: 1,
      title: '24 Hours',
      status: 'Blood Sugar Normalizing',
      description: 'Blood sugar stabilizes. Anxiety may peak as your body adjusts.',
      notificationBody: 'One day down. Keep going!',
    ),
    RecoveryMilestone(
      dayThreshold: 3,
      title: '72 Hours',
      status: 'Acute Withdrawal Passing',
      description: 'The most dangerous withdrawal period is ending. Your body begins healing.',
      notificationBody: 'Three days strong. The hardest part is passing.',
    ),
    RecoveryMilestone(
      dayThreshold: 7,
      title: '1 Week',
      status: 'Sleep Patterns Improving',
      description: 'REM sleep normalizes. You may feel more rested and mentally clear.',
      notificationBody: 'One week sober! Sleep and clarity improving.',
    ),
    RecoveryMilestone(
      dayThreshold: 14,
      title: '2 Weeks',
      status: 'Reduced Anxiety',
      description: 'Anxiety and depression decrease. Stomach lining begins to heal.',
      notificationBody: 'Two weeks! Anxiety decreasing, energy increasing.',
    ),
    RecoveryMilestone(
      dayThreshold: 30,
      title: '1 Month',
      status: 'Liver Fat Reducing',
      description: 'Liver fat can reduce by up to 15%. Blood pressure normalizing.',
      notificationBody: '30 days sober! Your body is healing visibly.',
    ),
    RecoveryMilestone(
      dayThreshold: 90,
      title: '3 Months',
      status: 'Liver Healing',
      description: 'Significant liver regeneration. Cardiovascular health markedly improved.',
      notificationBody: '90 days! Major healing milestone reached.',
    ),
    RecoveryMilestone(
      dayThreshold: 365,
      title: '1 Year',
      status: 'Full Recovery Mode',
      description: 'Risk of heart disease, stroke, and many cancers significantly reduced.',
      notificationBody: 'One year! A transformed life.',
    ),
  ];

  // ============ NICOTINE MILESTONES ============
  static const List<RecoveryMilestone> nicotineMilestones = [
    RecoveryMilestone(
      dayThreshold: 0,
      title: 'First Hours',
      status: 'Nicotine Leaving',
      description: 'Within 20 mins heart rate drops. Within 12 hours CO levels normalize.',
      notificationBody: 'Your body is already healing.',
    ),
    RecoveryMilestone(
      dayThreshold: 1,
      title: '24 Hours',
      status: 'Heart Attack Risk Drops',
      description: 'Heart attack risk begins to decrease. Nicotine leaves bloodstream.',
      notificationBody: 'One day smoke-free!',
    ),
    RecoveryMilestone(
      dayThreshold: 3,
      title: '72 Hours',
      status: 'Nicotine-Free',
      description: 'Nicotine fully eliminated. Breathing becomes easier. Cravings peak.',
      notificationBody: 'Three days! Cravings are peaking but will ease.',
    ),
    RecoveryMilestone(
      dayThreshold: 14,
      title: '2 Weeks',
      status: 'Circulation Improving',
      description: 'Blood circulation dramatically improves. Walking becomes easier.',
      notificationBody: 'Two weeks! Circulation is recovering.',
    ),
    RecoveryMilestone(
      dayThreshold: 30,
      title: '1 Month',
      status: 'Lung Cilia Regenerating',
      description: 'Lung cilia begin regrowing. Coughing and shortness of breath decrease.',
      notificationBody: '30 days! Lungs are healing.',
    ),
    RecoveryMilestone(
      dayThreshold: 90,
      title: '3 Months',
      status: 'Lung Function Up 30%',
      description: 'Lung function increases up to 30%. Energy levels significantly higher.',
      notificationBody: '90 days! Breathing easier than ever.',
    ),
    RecoveryMilestone(
      dayThreshold: 365,
      title: '1 Year',
      status: 'Heart Disease Risk Halved',
      description: 'Coronary heart disease risk is now half that of a smoker.',
      notificationBody: 'One year smoke-free!',
    ),
  ];

  // ============ PORN/NOFAP MILESTONES ============
  static const List<RecoveryMilestone> pornMilestones = [
    RecoveryMilestone(
      dayThreshold: 0,
      title: 'Day Zero',
      status: 'Brain Reset Begins',
      description: 'Your brain starts reducing dopamine tolerance from artificial stimulation.',
      notificationBody: 'The rewiring begins now.',
    ),
    RecoveryMilestone(
      dayThreshold: 7,
      title: '1 Week',
      status: 'Testosterone Spike',
      description: 'Testosterone peaks around day 7. Energy and motivation may increase.',
      notificationBody: 'One week! Energy levels rising.',
    ),
    RecoveryMilestone(
      dayThreshold: 14,
      title: '2 Weeks',
      status: 'Dopamine Rebalancing',
      description: 'Dopamine receptors begin upregulating. Pleasure from everyday activities increases.',
      notificationBody: 'Two weeks! Enjoying life more.',
    ),
    RecoveryMilestone(
      dayThreshold: 30,
      title: '1 Month',
      status: 'Mental Clarity',
      description: 'Brain fog lifts. Focus and concentration improve significantly.',
      notificationBody: '30 days! Mind is clearing.',
    ),
    RecoveryMilestone(
      dayThreshold: 60,
      title: '2 Months',
      status: 'Confidence Rising',
      description: 'Social anxiety decreases. Eye contact and confidence improve.',
      notificationBody: '60 days! Social confidence growing.',
    ),
    RecoveryMilestone(
      dayThreshold: 90,
      title: '90 Days',
      status: 'Full Reboot',
      description: 'Major neural rewiring complete. Significant improvements in all areas.',
      notificationBody: '90 days! Brain reboot complete.',
    ),
    RecoveryMilestone(
      dayThreshold: 180,
      title: '6 Months',
      status: 'New Normal',
      description: 'Healthy reward pathways established. Natural attraction restored.',
      notificationBody: 'Half a year! This is your new normal.',
    ),
  ];

  // ============ CAFFEINE MILESTONES ============
  static const List<RecoveryMilestone> caffeineMilestones = [
    RecoveryMilestone(
      dayThreshold: 0,
      title: 'Hours 0-12',
      status: 'Withdrawal Begins',
      description: 'Headaches may begin within 12-24 hours as caffeine leaves your system.',
      notificationBody: 'Stay strong through the headaches.',
    ),
    RecoveryMilestone(
      dayThreshold: 2,
      title: '48 Hours',
      status: 'Peak Withdrawal',
      description: 'Headaches peak. Fatigue and irritability are strongest now.',
      notificationBody: 'Two days! The worst is passing.',
    ),
    RecoveryMilestone(
      dayThreshold: 7,
      title: '1 Week',
      status: 'Headaches Fading',
      description: 'Physical withdrawal symptoms significantly reduced. Sleep improving.',
      notificationBody: 'One week! Sleep is getting better.',
    ),
    RecoveryMilestone(
      dayThreshold: 14,
      title: '2 Weeks',
      status: 'Natural Energy',
      description: 'Energy levels stabilize without caffeine. No more afternoon crashes.',
      notificationBody: 'Two weeks! Natural energy restored.',
    ),
    RecoveryMilestone(
      dayThreshold: 30,
      title: '1 Month',
      status: 'Sleep Quality Restored',
      description: 'Deep sleep significantly improved. Anxiety levels reduced.',
      notificationBody: '30 days! Sleeping like a baby.',
    ),
    RecoveryMilestone(
      dayThreshold: 90,
      title: '3 Months',
      status: 'Adrenal Recovery',
      description: 'Adrenal glands recovered. Stable energy throughout the day.',
      notificationBody: '90 days caffeine-free!',
    ),
  ];

  // ============ CANNABIS/WEED MILESTONES ============
  static const List<RecoveryMilestone> weedMilestones = [
    RecoveryMilestone(
      dayThreshold: 0,
      title: 'Day Zero',
      status: 'THC Detox Begins',
      description: 'THC begins leaving fat cells. Sleep disturbances may occur.',
      notificationBody: 'The clearing begins.',
    ),
    RecoveryMilestone(
      dayThreshold: 3,
      title: '72 Hours',
      status: 'REM Rebound',
      description: 'Vivid dreams return as REM sleep rebounds. Sleep may be restless.',
      notificationBody: 'Three days! Dreams returning.',
    ),
    RecoveryMilestone(
      dayThreshold: 7,
      title: '1 Week',
      status: 'Appetite Normalizing',
      description: 'Natural appetite signals return. Irritability decreasing.',
      notificationBody: 'One week! Appetite stabilizing.',
    ),
    RecoveryMilestone(
      dayThreshold: 14,
      title: '2 Weeks',
      status: 'Mental Clarity Starting',
      description: 'Brain fog begins to lift. Short-term memory improving.',
      notificationBody: 'Two weeks! Mind is clearing.',
    ),
    RecoveryMilestone(
      dayThreshold: 30,
      title: '1 Month',
      status: 'Motivation Returning',
      description: 'Drive and motivation increase. Anhedonia fading.',
      notificationBody: '30 days! Feeling motivated again.',
    ),
    RecoveryMilestone(
      dayThreshold: 90,
      title: '3 Months',
      status: 'Full THC Clearance',
      description: 'THC largely cleared from body. Cognitive function restored.',
      notificationBody: '90 days! System cleared.',
    ),
  ];

  // ============ GENERIC MILESTONES ============
  static const List<RecoveryMilestone> genericMilestones = [
    RecoveryMilestone(
      dayThreshold: 0,
      title: 'Day Zero',
      status: 'Fresh Start',
      description: 'Your recovery journey begins. Every step forward counts.',
      notificationBody: 'Day one of your new life.',
    ),
    RecoveryMilestone(
      dayThreshold: 7,
      title: '1 Week',
      status: 'Building Momentum',
      description: 'One week of progress. New habits are forming.',
      notificationBody: 'One week strong!',
    ),
    RecoveryMilestone(
      dayThreshold: 30,
      title: '1 Month',
      status: 'Habit Forming',
      description: 'A full month of change. Your new patterns are solidifying.',
      notificationBody: '30 days! A new habit is born.',
    ),
    RecoveryMilestone(
      dayThreshold: 90,
      title: '3 Months',
      status: 'Lifestyle Change',
      description: 'Quarter of a year. This is becoming your new normal.',
      notificationBody: '90 days! This is who you are now.',
    ),
    RecoveryMilestone(
      dayThreshold: 365,
      title: '1 Year',
      status: 'Transformed',
      description: 'A full year of recovery. You have proven your strength.',
      notificationBody: 'One year! Incredible achievement.',
    ),
  ];
}
