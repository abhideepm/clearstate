import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/subscription_provider.dart';
import '../theme/colors.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClearStateColors.charcoal,
        border: Border.all(color: ClearStateColors.acidGreen, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 32, color: ClearStateColors.acidGreen),
          const SizedBox(height: 12),
          Text(
            'PRO FEATURE',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
          if (featureName != null) ...[
            const SizedBox(height: 4),
            Text(
              featureName!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to paywall or show purchase sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchase Pro to unlock this feature')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ClearStateColors.acidGreen,
              foregroundColor: Colors.black,
              shape: const RoundedRectangleBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('UNLOCK NOW'),
          ),
        ],
      ),
    );
  }
}
