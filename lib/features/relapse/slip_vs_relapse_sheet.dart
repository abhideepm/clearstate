import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/services/haptic_service.dart';
import '../../data/repositories/sobriety_repository.dart';
import '../timer/timer_provider.dart';
import 'widgets/drink_input_sheet.dart';
import 'widgets/slip_pattern_dialog.dart';

/// Main sheet that asks user to categorize their incident as a slip or relapse.
/// This is the "anti-shame" logic that preserves psychological momentum.
class SlipVsRelapseSheet extends ConsumerStatefulWidget {
  const SlipVsRelapseSheet({super.key});

  @override
  ConsumerState<SlipVsRelapseSheet> createState() => _SlipVsRelapseSheetState();
}

class _SlipVsRelapseSheetState extends ConsumerState<SlipVsRelapseSheet> {
  bool _isLogging = false;

  @override
  Widget build(BuildContext context) {
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
                color: ClearStateColors.ash,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'HOW WOULD YOU DESCRIBE THIS?',
            style: ClearStateTypography.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your choice affects how we track your progress',
            style: ClearStateTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // SLIP option
          _ChoiceCard(
            title: 'A MOMENTARY SLIP',
            subtitle: 'A one-time incident. Your timer continues.',
            icon: Icons.water_drop_outlined,
            color: ClearStateColors.signal,
            isLoading: _isLogging,
            onTap: () => _showDrinkInput(isSlip: true),
          ),
          const SizedBox(height: 16),

          // RELAPSE option
          _ChoiceCard(
            title: 'A FULL RELAPSE',
            subtitle: 'Back to old patterns. Timer resets.',
            icon: Icons.restart_alt,
            color: ClearStateColors.relapse,
            isLoading: _isLogging,
            onTap: () => _showDrinkInput(isSlip: false),
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
              style: ClearStateTypography.button.copyWith(
                color: ClearStateColors.smoke,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDrinkInput({required bool isSlip}) {
    HapticService.medium();
    Navigator.pop(context); // Close this sheet

    showModalBottomSheet(
      context: context,
      backgroundColor: ClearStateColors.charcoal,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (context) => DrinkInputSheet(
        isSlip: isSlip,
        onConfirm: (drinks, cost, calories, drinkType) async {
          await _logEvent(
            isSlip: isSlip,
            drinks: drinks,
            cost: cost,
            calories: calories,
            drinkType: drinkType,
          );
        },
      ),
    );
  }

  Future<void> _logEvent({
    required bool isSlip,
    required int drinks,
    required double cost,
    required int calories,
    required String drinkType,
  }) async {
    setState(() => _isLogging = true);

    final repository = ref.read(sobrietyRepositoryProvider);

    if (isSlip) {
      await repository.logSlip(
        drinksConsumed: drinks,
        costIncurred: cost,
        caloriesConsumed: calories,
        drinkType: drinkType,
      );

      // Check for slip pattern (3+ slips in a week)
      final slipsThisWeek = repository.getSlipsThisWeek();
      if (slipsThisWeek >= 3 && mounted) {
        HapticService.medium();
        // Show gentle prompt dialog
        _showSlipPatternDialog();
      } else {
        HapticService.success();
      }
    } else {
      await repository.logRelapse(
        drinksConsumed: drinks,
        costIncurred: cost,
        caloriesConsumed: calories,
        drinkType: drinkType,
      );

      // Reset the timer state
      ref.read(sobrietyStartDateProvider.notifier).state = DateTime.now();
      HapticService.relapseConfirm();
    }

    setState(() => _isLogging = false);
  }

  void _showSlipPatternDialog() {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => SlipPatternDialog(
        onKeepAsSlips: () {
          Navigator.pop(dialogContext);
        },
        onConvertToRelapse: () async {
          final repository = ref.read(sobrietyRepositoryProvider);
          await repository.convertSlipsToRelapse();
          ref.read(sobrietyStartDateProvider.notifier).state = DateTime.now();
          HapticService.relapseConfirm();
          navigator.pop();
        },
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
  final bool isLoading;

  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ClearStateColors.void_,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
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
                    style: ClearStateTypography.button.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: ClearStateTypography.caption.copyWith(
                      color: ClearStateColors.smoke,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: ClearStateColors.ash),
          ],
        ),
      ),
    );
  }
}
