enum SubscriptionTier {
  free,
  pro,
}

class SubscriptionStatus {
  final SubscriptionTier tier;
  final bool isActive;
  final DateTime? expirationDate;

  const SubscriptionStatus({
    required this.tier,
    this.isActive = false,
    this.expirationDate,
  });

  bool get isPro => tier == SubscriptionTier.pro && isActive;

  factory SubscriptionStatus.free() => const SubscriptionStatus(
        tier: SubscriptionTier.free,
        isActive: true,
      );

  @override
  String toString() => 'SubscriptionStatus(tier: $tier, isActive: $isActive)';
}
