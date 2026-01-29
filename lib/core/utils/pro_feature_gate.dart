import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/subscription_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/theme_provider.dart';

class ProFeatureGate extends ConsumerWidget {
  final Widget child;
  final Widget? lockedBuilder;
  final String? featureName;

  const ProFeatureGate({
    super.key,
    required this.child,
    this.lockedBuilder,
    this.featureName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionStatusProvider);

    if (subscription.isPro) {
      return child;
    }

    if (lockedBuilder != null) {
      return lockedBuilder!;
    }

    return LockedPlaceholder(featureName: featureName);
  }
}

class LockedPlaceholder extends ConsumerWidget {
  final String? featureName;

  const LockedPlaceholder({super.key, this.featureName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final accentValue = themeState.accentValue;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeState.surface,
        border: Border.all(
          color: accentValue.withValues(alpha: 0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentValue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 28,
              color: accentValue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PRO FEATURE',
            style: TrueStateTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: accentValue,
            ),
          ),
          if (featureName != null) ...[
            const SizedBox(height: 8),
            Text(
              featureName!,
              textAlign: TextAlign.center,
              style: TrueStateTypography.bodySecondary,
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchase Pro to unlock this feature')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentValue,
                foregroundColor: themeState.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                elevation: 0,
              ),
              child: Text(
                'UNLOCK PRO',
                style: TrueStateTypography.button.copyWith(
                  color: themeState.background,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
