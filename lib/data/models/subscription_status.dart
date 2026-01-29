enum SubscriptionTier { free, pro }

enum PlanType { none, monthly, yearly, lifetime }

class SubscriptionStatus {
  final SubscriptionTier tier;
  final bool isActive;
  final bool isTrialing;
  final DateTime? expirationDate;
  final DateTime? trialEndDate;
  final PlanType planType;

  const SubscriptionStatus({
    required this.tier,
    this.isActive = false,
    this.isTrialing = false,
    this.expirationDate,
    this.trialEndDate,
    this.planType = PlanType.none,
  });

  bool get isPro => tier == SubscriptionTier.pro && isActive;
  bool get hasAccess => isPro || isTrialing;
  bool get isLifetime => planType == PlanType.lifetime;

  factory SubscriptionStatus.free() =>
      const SubscriptionStatus(tier: SubscriptionTier.free, isActive: true);

  factory SubscriptionStatus.trial({required DateTime trialEndDate}) =>
      SubscriptionStatus(
        tier: SubscriptionTier.pro,
        isActive: true,
        isTrialing: true,
        trialEndDate: trialEndDate,
      );

  @override
  String toString() =>
      'SubscriptionStatus(tier: $tier, isActive: $isActive, isTrialing: $isTrialing, plan: $planType)';
}
