import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography.dart';
import '../../../data/repositories/sobriety_repository.dart';
import '../../settings/subscription_provider.dart';
import '../paywall_screen.dart';
import '../../../core/theme/theme_provider.dart';

/// Banner showing trial days remaining, tappable to show paywall
class TrialBanner extends ConsumerWidget {
  const TrialBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(subscriptionStatusProvider);
    final repository = ref.watch(sobrietyRepositoryProvider);
    final profile = repository.getUserProfile();

    // Don't show if already pro (paid)
    if (status.isPro && !status.isTrialing) return const SizedBox.shrink();

    // Check trial status
    final isTrialing = status.isTrialing || (profile?.isInTrial ?? false);
    if (!isTrialing) return const SizedBox.shrink();

    final daysRemaining = profile?.trialDaysRemaining ?? 0;
    if (daysRemaining <= 0) return const SizedBox.shrink();

    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accentValue;

    return GestureDetector(
      onTap: () => _showPaywall(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withValues(alpha: 0.2),
              accentColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.star, color: accentColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$daysRemaining day${daysRemaining == 1 ? '' : 's'} left in trial',
                    style: TrueStateTypography.bodySemiBold.copyWith(
                      color: accentColor,
                    ),
                  ),
                  Text(
                    'Tap to keep your Pro features',
                    style: TrueStateTypography.caption.copyWith(
                      color: themeState.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: accentColor),
          ],
        ),
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PaywallScreen(),
      ),
    );
  }
}
