import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/sobriety_orchestrator.dart';
import '../../../data/repositories/sobriety_repository.dart';
import '../../timer/timer_provider.dart';
import 'slip_pattern_dialog.dart';

/// Simplified sheet for logging a slip or relapse.
class DrinkInputSheet extends ConsumerStatefulWidget {
  final bool isSlip;

  const DrinkInputSheet({super.key, required this.isSlip});

  @override
  ConsumerState<DrinkInputSheet> createState() => _DrinkInputSheetState();
}

class _DrinkInputSheetState extends ConsumerState<DrinkInputSheet> {
  bool _isLogging = false;

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
              widget.isSlip ? 'LOG SLIP' : 'LOG RELAPSE',
              style: TrueStateTypography.h2.copyWith(
                color: widget.isSlip ? accentColor : TrueStateColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              widget.isSlip
                  ? 'A momentary slip won\'t reset your progress.'
                  : 'This will reset your timer and start fresh.',
              style: TrueStateTypography.bodySecondary.copyWith(
                color: themeState.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Confirm button
            ElevatedButton(
              onPressed: _isLogging ? null : _handleConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isSlip
                    ? accentColor
                    : TrueStateColors.error,
              ),
              child: _isLogging
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TrueStateColors.darkBackground,
                      ),
                    )
                  : Text(widget.isSlip ? 'LOG SLIP' : 'LOG RELAPSE'),
            ),
            const SizedBox(height: 12),

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
      ),
    );
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLogging = true);

    try {
      final orchestrator = ref.read(sobrietyOrchestratorProvider);
      final repository = ref.read(sobrietyRepositoryProvider);
      final profile = repository.getUserProfile();
      final habitId = profile?.selectedHabitIds.isNotEmpty == true
          ? profile!.selectedHabitIds.first
          : null;

      if (habitId == null) {
        if (mounted) {
          setState(() => _isLogging = false);
        }
        return;
      }

      if (widget.isSlip) {
        await orchestrator.logSlip(habitId);

        // Check for slip pattern (3+ slips in a week)
        final slipsThisWeek = repository.getSlipsThisWeek(habitId);
        if (slipsThisWeek >= 3 && mounted) {
          HapticService.medium();
          _showSlipPatternDialog();
          return;
        } else {
          HapticService.success();
        }
      } else {
        await orchestrator.logRelapse(habitId);

        // Reset the timer state
        ref.read(sobrietyStartDateProvider.notifier).state = DateTime.now();
        HapticService.relapseConfirm();
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLogging = false);
      }
    }
  }

  void _showSlipPatternDialog() {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final repository = ref.read(sobrietyRepositoryProvider);
    final profile = repository.getUserProfile();
    final habitId = profile?.selectedHabitIds.isNotEmpty == true
        ? profile!.selectedHabitIds.first
        : null;

    if (habitId == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => SlipPatternDialog(
        onKeepAsSlips: () {
          Navigator.pop(dialogContext);
          navigator.pop();
        },
        onConvertToRelapse: () async {
          final dialogNavigator = Navigator.of(dialogContext);
          final orchestrator = ref.read(sobrietyOrchestratorProvider);
          await orchestrator.convertSlipsToRelapse(habitId);
          ref.read(sobrietyStartDateProvider.notifier).state = DateTime.now();
          HapticService.relapseConfirm();
          dialogNavigator.pop();
          navigator.pop();
        },
      ),
    );
  }
}
