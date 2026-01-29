import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/subscription_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

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

class LockedPlaceholder extends StatelessWidget {
  final String? featureName;

  const LockedPlaceholder({super.key, this.featureName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ClearStateColors.darkSurface,
        border: Border.all(
          color: ClearStateColors.lavender.withValues(alpha: 0.4),
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
              color: ClearStateColors.lavender.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 28,
              color: ClearStateColors.lavender,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PRO FEATURE',
            style: ClearStateTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: ClearStateColors.lavender,
            ),
          ),
          if (featureName != null) ...[
            const SizedBox(height: 8),
            Text(
              featureName!,
              textAlign: TextAlign.center,
              style: ClearStateTypography.bodySecondary,
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
                backgroundColor: ClearStateColors.lavender,
                foregroundColor: ClearStateColors.darkBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                elevation: 0,
              ),
              child: Text(
                'UNLOCK PRO',
                style: ClearStateTypography.button.copyWith(
                  color: ClearStateColors.darkBackground,
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
