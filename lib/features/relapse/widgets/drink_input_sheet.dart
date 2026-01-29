import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/sobriety_orchestrator.dart';
import '../../../core/constants/drink_presets.dart';
import '../../../data/repositories/sobriety_repository.dart';
import '../../timer/timer_provider.dart';
import 'slip_pattern_dialog.dart';

/// Sheet for inputting drink details (quantity, type, cost).
/// Used for both slips and relapses.
class DrinkInputSheet extends ConsumerStatefulWidget {
  final bool isSlip;

  const DrinkInputSheet({super.key, required this.isSlip});

  @override
  ConsumerState<DrinkInputSheet> createState() => _DrinkInputSheetState();
}

class _DrinkInputSheetState extends ConsumerState<DrinkInputSheet> {
  int _drinks = 1;
  String _drinkType = 'Beer';
  bool _isLogging = false;

  DrinkPreset get _currentPreset => DrinkPresets.getByName(_drinkType);
  double get _totalCost => _drinks * _currentPreset.defaultCost;
  int get _totalCalories => _drinks * _currentPreset.defaultCalories;

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
                  color: ClearStateColors.borderDark,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.isSlip ? 'LOG SLIP' : 'LOG RELAPSE',
              style: ClearStateTypography.h2.copyWith(
                color: widget.isSlip ? accentColor : ClearStateColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Drink type selector
            Text(
              'DRINK TYPE',
              style: ClearStateTypography.caption.copyWith(
                color: ClearStateColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 12),
            _DrinkTypeSelector(
              selectedType: _drinkType,
              accentColor: accentColor,
              onChanged: (type) {
                HapticService.light();
                setState(() => _drinkType = type);
              },
            ),
            const SizedBox(height: 24),

            // Quantity selector
            Text(
              'HOW MANY?',
              style: ClearStateTypography.caption.copyWith(
                color: ClearStateColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 12),
            _QuantitySelector(
              value: _drinks,
              onChanged: (value) {
                HapticService.light();
                setState(() => _drinks = value);
              },
            ),
            const SizedBox(height: 24),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ClearStateColors.darkBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ClearStateColors.borderDark),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    label: 'COST',
                    value: '\$${_totalCost.toStringAsFixed(0)}',
                  ),
                  Container(width: 1, height: 32, color: ClearStateColors.borderDark),
                  _SummaryItem(label: 'CALORIES', value: '$_totalCalories'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Confirm button
            ElevatedButton(
              onPressed: _isLogging ? null : _handleConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isSlip
                    ? accentColor
                    : ClearStateColors.error,
              ),
              child: _isLogging
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ClearStateColors.darkBackground,
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
                style: ClearStateTypography.button.copyWith(
                  color: ClearStateColors.textSecondaryDark,
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
        await orchestrator.logSlip(
          habitId,
          drinksConsumed: _drinks,
          costIncurred: _totalCost,
          caloriesConsumed: _totalCalories,
          drinkType: _drinkType,
        );

        // Check for slip pattern (3+ slips in a week)
        final slipsThisWeek = repository.getSlipsThisWeek(habitId);
        if (slipsThisWeek >= 3 && mounted) {
          HapticService.medium();
          _showSlipPatternDialog();
          return; // Don't pop - dialog will handle navigation
        } else {
          HapticService.success();
        }
      } else {
        await orchestrator.logRelapse(
          habitId,
          drinksConsumed: _drinks,
          costIncurred: _totalCost,
          caloriesConsumed: _totalCalories,
          drinkType: _drinkType,
        );

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
          navigator.pop(); // Close this sheet
        },
        onConvertToRelapse: () async {
          final dialogNavigator = Navigator.of(dialogContext);
          final orchestrator = ref.read(sobrietyOrchestratorProvider);
          await orchestrator.convertSlipsToRelapse(habitId);
          ref.read(sobrietyStartDateProvider.notifier).state = DateTime.now();
          HapticService.relapseConfirm();
          dialogNavigator.pop();
          navigator.pop(); // Close this sheet
        },
      ),
    );
  }
}

/// Horizontal drink type selector.
class _DrinkTypeSelector extends StatelessWidget {
  final String selectedType;
  final Color accentColor;
  final ValueChanged<String> onChanged;

  const _DrinkTypeSelector({
    required this.selectedType,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: DrinkPresets.presets.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final preset = DrinkPresets.presets[index];
          final isSelected = preset.name == selectedType;
          return GestureDetector(
            onTap: () => onChanged(preset.name),
            child: Container(
              width: 64,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.15)
                    : ClearStateColors.darkBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? accentColor : ClearStateColors.borderDark,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(preset.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(
                    preset.name,
                    style: ClearStateTypography.caption.copyWith(
                      fontSize: 8,
                      color: isSelected
                          ? ClearStateColors.textPrimaryDark
                          : ClearStateColors.textSecondaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Quantity stepper with +/- buttons.
class _QuantitySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ClearStateColors.darkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ClearStateColors.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Column(
            children: [
              Text('$value', style: ClearStateTypography.statNumber),
              Text(
                value == 1 ? 'DRINK' : 'DRINKS',
                style: ClearStateTypography.caption.copyWith(
                  color: ClearStateColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          _StepperButton(
            icon: Icons.add,
            onPressed: value < 20 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepperButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isEnabled
              ? ClearStateColors.darkSurface
              : ClearStateColors.darkSurface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isEnabled ? ClearStateColors.textPrimaryDark : ClearStateColors.borderDark,
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: ClearStateTypography.caption.copyWith(
            color: ClearStateColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: ClearStateTypography.statNumber.copyWith(fontSize: 20),
        ),
      ],
    );
  }
}
