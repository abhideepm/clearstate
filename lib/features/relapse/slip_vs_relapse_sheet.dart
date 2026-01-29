import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';
import 'widgets/drink_input_sheet.dart';

/// Main sheet that asks user to categorize their incident as a slip or relapse.
/// This is the "anti-shame" logic that preserves psychological momentum.
class SlipVsRelapseSheet extends ConsumerWidget {
  const SlipVsRelapseSheet({super.key});

  void _showDrinkInput(BuildContext context, {required bool isSlip}) {
    HapticService.medium();
    Navigator.pop(context); // Close this sheet

    showModalBottomSheet(
      context: context,
      backgroundColor: TrueStateColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (sheetContext) => DrinkInputSheet(isSlip: isSlip),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TrueStateColors.borderDark,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'HOW WOULD YOU DESCRIBE THIS?',
            style: TrueStateTypography.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your choice affects how we track your progress',
            style: TrueStateTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // SLIP option
          _ChoiceCard(
            title: 'A MOMENTARY SLIP',
            subtitle: 'A one-time incident. Your timer continues.',
            icon: Icons.water_drop_outlined,
            color: accentColor,
            onTap: () => _showDrinkInput(context, isSlip: true),
          ),
          const SizedBox(height: 16),

          // RELAPSE option
          _ChoiceCard(
            title: 'A FULL RELAPSE',
            subtitle: 'Back to old patterns. Timer resets.',
            icon: Icons.restart_alt,
            color: TrueStateColors.error,
            onTap: () => _showDrinkInput(context, isSlip: false),
          ),
          const SizedBox(height: 24),

          // Cancel
          TextButton(
            onPressed: () {
              HapticService.light();
              Navigator.pop(context);
            },
            child: Text(
              'CANCEL',
              style: TrueStateTypography.button.copyWith(
                color: TrueStateColors.textSecondaryDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Choice card for slip vs relapse selection.
class _ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TrueStateColors.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TrueStateTypography.button.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TrueStateTypography.caption.copyWith(
                      color: TrueStateColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: TrueStateColors.borderDark),
          ],
        ),
      ),
    );
  }
}
