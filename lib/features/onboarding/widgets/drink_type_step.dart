import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/drink_presets.dart';
import '../onboarding_provider.dart';

class DrinkTypeStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DrinkTypeStep({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<DrinkTypeStep> createState() => _DrinkTypeStepState();
}

class _DrinkTypeStepState extends ConsumerState<DrinkTypeStep> {
  String _selected = 'Beer';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            'YOUR DRINK\nOF CHOICE?',
            style: ClearStateTypography.h1.copyWith(fontSize: 32, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'We\'ll use this as your default',
            style: ClearStateTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: DrinkPresets.presets.map((preset) {
              final isSelected = _selected == preset.name;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selected = preset.name);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ClearStateColors.signal
                        : ClearStateColors.charcoal,
                    border: Border.all(
                      color: isSelected
                          ? ClearStateColors.signal
                          : ClearStateColors.ash,
                    ),
                  ),
                  child: Text(
                    preset.name.toUpperCase(),
                    style: ClearStateTypography.button.copyWith(
                      color: isSelected
                          ? ClearStateColors.void_
                          : ClearStateColors.bone,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              ref.read(onboardingProvider.notifier).setDrinkType(_selected);
              widget.onNext();
            },
            child: const Text('CONTINUE'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onBack,
            child: Text(
              'BACK',
              style: ClearStateTypography.button.copyWith(
                color: ClearStateColors.smoke,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
