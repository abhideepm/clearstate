import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../../../data/repositories/sobriety_repository.dart';
import '../../timer/timer_provider.dart';
import '../notification_provider.dart';

/// Confirmation dialog for nuclear data wipe.
/// Requires user to type "DELETE" to confirm.
class WipeConfirmationDialog extends ConsumerStatefulWidget {
  final VoidCallback onWipeComplete;

  const WipeConfirmationDialog({super.key, required this.onWipeComplete});

  @override
  ConsumerState<WipeConfirmationDialog> createState() =>
      _WipeConfirmationDialogState();
}

class _WipeConfirmationDialogState
    extends ConsumerState<WipeConfirmationDialog> {
  final _textController = TextEditingController();
  bool _isDeleting = false;

  bool get _canConfirm =>
      _textController.text.toUpperCase() == 'DELETE' && !_isDeleting;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _performWipe() async {
    if (!_canConfirm) return;

    setState(() => _isDeleting = true);
    HapticService.heavy();

    try {
      // Wipe all data (this also cancels pending notifications)
      final repository = ref.read(sobrietyRepositoryProvider);
      await repository.nukeAllData();

      // Reset app state providers
      ref.read(sobrietyStartDateProvider.notifier).state = null;
      ref.read(onboardingProvider.notifier).reset();

      // Reset notification settings to default (enabled)
      await ref.read(notificationSettingsProvider.notifier).setEnabled(true);

      HapticService.success();

      // Close dialog and trigger callback
      if (mounted) {
        Navigator.of(context).pop();
        widget.onWipeComplete();
      }
    } catch (e) {
      HapticService.error();
      setState(() => _isDeleting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete data: $e'),
            backgroundColor: ClearStateColors.relapse,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ClearStateColors.charcoal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: const BorderSide(color: ClearStateColors.ash, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ClearStateColors.relapse.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: ClearStateColors.relapse,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'DELETE ALL DATA?',
              style: ClearStateTypography.h2.copyWith(
                color: ClearStateColors.relapse,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Warning text
            Text(
              'This action cannot be undone. The following will be permanently deleted:',
              style: ClearStateTypography.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // List of what will be deleted
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ClearStateColors.relapse.withOpacity(0.08),
                border: Border.all(
                  color: ClearStateColors.relapse.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WipeItem(text: 'Your sobriety history'),
                  const SizedBox(height: 8),
                  _WipeItem(text: 'All logged events'),
                  const SizedBox(height: 8),
                  _WipeItem(text: 'Your settings & preferences'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirmation input
            Text(
              'Type DELETE to confirm',
              style: ClearStateTypography.caption.copyWith(
                color: ClearStateColors.smoke,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              enabled: !_isDeleting,
              style: ClearStateTypography.body.copyWith(
                color: ClearStateColors.bone,
              ),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'DELETE',
                hintStyle: ClearStateTypography.body.copyWith(
                  color: ClearStateColors.ash,
                ),
                filled: true,
                fillColor: ClearStateColors.void_,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: const BorderSide(
                    color: ClearStateColors.ash,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: const BorderSide(
                    color: ClearStateColors.ash,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: const BorderSide(
                    color: ClearStateColors.relapse,
                    width: 1,
                  ),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'CANCEL',
                    onPressed: _isDeleting
                        ? null
                        : () {
                            HapticService.light();
                            Navigator.of(context).pop();
                          },
                    isDestructive: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: _isDeleting ? 'DELETING...' : 'CONFIRM',
                    onPressed: _canConfirm ? _performWipe : null,
                    isDestructive: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WipeItem extends StatelessWidget {
  final String text;

  const _WipeItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: ClearStateColors.relapse,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: ClearStateTypography.body.copyWith(
              color: ClearStateColors.bone,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;

  const _DialogButton({
    required this.label,
    required this.onPressed,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDestructive
              ? (enabled
                    ? ClearStateColors.relapse
                    : ClearStateColors.relapse.withOpacity(0.3))
              : ClearStateColors.graphite,
          border: Border.all(
            color: isDestructive
                ? (enabled
                      ? ClearStateColors.relapse
                      : ClearStateColors.relapse.withOpacity(0.3))
                : ClearStateColors.ash,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: ClearStateTypography.button.copyWith(
            color: enabled ? ClearStateColors.bone : ClearStateColors.smoke,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
