import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../settings/subscription_provider.dart';

/// Full-screen paywall with psychological pricing design
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;

  Future<void> _purchase(Future<bool> Function() purchaseFn) async {
    setState(() => _isLoading = true);
    try {
      final success = await purchaseFn();
      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(subscriptionStatusProvider.notifier).restorePurchases();
      final status = ref.read(subscriptionStatusProvider);
      if (status.isPro && mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final notifier = ref.read(subscriptionStatusProvider.notifier);

    return Scaffold(
      backgroundColor: ClearStateColors.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: ClearStateColors.textSecondaryDark),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Value proposition
                        Text('Unlock Your Full\nRecovery Journey',
                          style: ClearStateTypography.h1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Keep your insights, unlimited habits, and 24/7 crisis support',
                          style: ClearStateTypography.bodySecondary,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Feature list
                        const _FeatureList(),

                        const SizedBox(height: 32),

                        // Pricing cards
                        offeringsAsync.when(
                          data: (offerings) => _PricingGrid(
                            offerings: offerings,
                            onPurchaseMonthly: () => _purchase(notifier.purchaseMonthly),
                            onPurchaseQuarterly: () => _purchase(notifier.purchaseQuarterly),
                            onPurchaseAnnual: () => _purchase(notifier.purchaseAnnual),
                            onPurchaseLifetime: () => _purchase(notifier.purchaseLifetime),
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const _FallbackPricing(),
                        ),

                        const SizedBox(height: 24),

                        // Restore purchases
                        TextButton(
                          onPressed: _restore,
                          child: Text(
                            'Restore Purchases',
                            style: ClearStateTypography.caption.copyWith(
                              color: ClearStateColors.textTertiaryDark,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Continue free
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Continue with Free',
                            style: ClearStateTypography.bodySmall.copyWith(
                              color: ClearStateColors.textSecondaryDark,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    const features = [
      ('Unlimited habits', Icons.all_inclusive),
      ('AI Sponsor (24/7 support)', Icons.psychology),
      ('Deep analytics & trends', Icons.insights),
      ('Premium themes', Icons.palette),
      ('Cloud backup', Icons.cloud_done),
    ];

    return Column(
      children: features.map((f) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ClearStateColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(f.$2, color: ClearStateColors.accent, size: 20),
            ),
            const SizedBox(width: 16),
            Text(f.$1, style: ClearStateTypography.body),
          ],
        ),
      )).toList(),
    );
  }
}

class _PricingGrid extends StatelessWidget {
  final Offerings? offerings;
  final VoidCallback onPurchaseMonthly;
  final VoidCallback onPurchaseQuarterly;
  final VoidCallback onPurchaseAnnual;
  final VoidCallback onPurchaseLifetime;

  const _PricingGrid({
    required this.offerings,
    required this.onPurchaseMonthly,
    required this.onPurchaseQuarterly,
    required this.onPurchaseAnnual,
    required this.onPurchaseLifetime,
  });

  @override
  Widget build(BuildContext context) {
    final current = offerings?.current;
    final monthlyPrice = current?.monthly?.storeProduct.priceString ?? '\$4.99';
    final annualPrice = current?.annual?.storeProduct.priceString ?? '\$39.99';
    final lifetimePrice = current?.lifetime?.storeProduct.priceString ?? '\$79';

    return Column(
      children: [
        // Lifetime - Anchor (shown first)
        _PricingCard(
          title: 'Lifetime',
          price: lifetimePrice,
          subtitle: 'Pay once, own forever',
          isHighlighted: false,
          onTap: onPurchaseLifetime,
        ),
        const SizedBox(height: 12),

        // Annual - Target (best value)
        _PricingCard(
          title: 'Annual',
          price: annualPrice,
          subtitle: '\$3.33/month • Save 33%',
          badge: 'BEST VALUE',
          isHighlighted: true,
          onTap: onPurchaseAnnual,
        ),
        const SizedBox(height: 12),

        // Quarterly
        _PricingCard(
          title: 'Quarterly',
          price: '\$14.99',
          subtitle: '\$5.00/month',
          onTap: onPurchaseQuarterly,
        ),
        const SizedBox(height: 12),

        // Monthly - Decoy
        _PricingCard(
          title: 'Monthly',
          price: monthlyPrice,
          subtitle: 'Billed monthly',
          onTap: onPurchaseMonthly,
        ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final String? badge;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.subtitle,
    this.badge,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted
              ? ClearStateColors.accent.withOpacity(0.1)
              : ClearStateColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? ClearStateColors.accent
                : ClearStateColors.borderDark,
            width: isHighlighted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: ClearStateTypography.bodySemiBold),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ClearStateColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: ClearStateTypography.caption.copyWith(
                              color: ClearStateColors.darkBackground,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: ClearStateTypography.caption,
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: ClearStateTypography.h2.copyWith(
                color: isHighlighted
                    ? ClearStateColors.accent
                    : ClearStateColors.textPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackPricing extends StatelessWidget {
  const _FallbackPricing();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.cloud_off, color: ClearStateColors.textTertiaryDark, size: 48),
        const SizedBox(height: 16),
        Text(
          'Unable to load pricing.\nPlease check your connection.',
          style: ClearStateTypography.bodySecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
