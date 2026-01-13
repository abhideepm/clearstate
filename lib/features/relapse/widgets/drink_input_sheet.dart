import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/constants/drink_presets.dart';

/// Sheet for inputting drink details (quantity, type, cost).
/// Used for both slips and relapses.
class DrinkInputSheet extends StatefulWidget {
  final bool isSlip;
  final Future<void> Function(
    int drinks,
    double cost,
    int calories,
    String drinkType,
  )
  onConfirm;

  const DrinkInputSheet({
    super.key,
    required this.isSlip,
    required this.onConfirm,
  });

  @override
  State<DrinkInputSheet> createState() => _DrinkInputSheetState();
}

class _DrinkInputSheetState extends State<DrinkInputSheet> {
  int _drinks = 1;
  String _drinkType = 'Beer';
  bool _isLogging = false;

  DrinkPreset get _currentPreset => DrinkPresets.getByName(_drinkType);
  double get _totalCost => _drinks * _currentPreset.defaultCost;
  int get _totalCalories => _drinks * _currentPreset.defaultCalories;

  @override
  Widget build(BuildContext context) {
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
                  color: ClearStateColors.ash,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.isSlip ? 'LOG SLIP' : 'LOG RELAPSE',
              style: ClearStateTypography.h2.copyWith(
                color: widget.isSlip
                    ? ClearStateColors.signal
                    : ClearStateColors.relapse,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Drink type selector
            Text(
              'DRINK TYPE',
              style: ClearStateTypography.caption.copyWith(
                color: ClearStateColors.smoke,
              ),
            ),
            const SizedBox(height: 12),
            _DrinkTypeSelector(
              selectedType: _drinkType,
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
                color: ClearStateColors.smoke,
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
                color: ClearStateColors.void_,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: ClearStateColors.ash),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    label: 'COST',
                    value: '\$${_totalCost.toStringAsFixed(0)}',
                  ),
                  Container(width: 1, height: 32, color: ClearStateColors.ash),
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
                    ? ClearStateColors.signal
                    : ClearStateColors.relapse,
              ),
              child: _isLogging
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ClearStateColors.void_,
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
                  color: ClearStateColors.smoke,
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

    await widget.onConfirm(_drinks, _totalCost, _totalCalories, _drinkType);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

/// Horizontal drink type selector.
class _DrinkTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _DrinkTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: DrinkPresets.presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                    ? ClearStateColors.signal.withValues(alpha: 0.15)
                    : ClearStateColors.void_,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: isSelected
                      ? ClearStateColors.signal
                      : ClearStateColors.ash,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(preset.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    preset.name,
                    style: ClearStateTypography.caption.copyWith(
                      fontSize: 9,
                      color: isSelected
                          ? ClearStateColors.bone
                          : ClearStateColors.smoke,
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
        color: ClearStateColors.void_,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: ClearStateColors.ash),
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
                  color: ClearStateColors.smoke,
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
              ? ClearStateColors.charcoal
              : ClearStateColors.charcoal.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Icon(
          icon,
          color: isEnabled ? ClearStateColors.bone : ClearStateColors.ash,
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
            color: ClearStateColors.smoke,
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
