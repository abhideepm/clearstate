import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/drink_presets.dart';
import '../../../core/services/haptic_service.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/animated_chip.dart';
import '../../../shared/widgets/brutalist_button.dart';

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
              return AnimatedChip(
                isSelected: isSelected,
                onTap: () {
                  HapticService.selection();
                  setState(() => _selected = preset.name);
                },
                child: Text(preset.name.toUpperCase()),
              );
            }).toList(),
          ),
          const Spacer(),
          BrutalistButton(
            label: 'CONTINUE',
            onPressed: () {
              ref.read(onboardingProvider.notifier).setDrinkType(_selected);
              widget.onNext();
            },
            type: BrutalistButtonType.primary,
          ),
          const SizedBox(height: 12),
          BrutalistButton(
            label: 'SKIP',
            onPressed: () {
              ref.read(onboardingProvider.notifier).setDrinkType('');
              widget.onNext();
            },
            type: BrutalistButtonType.secondary,
          ),
          const SizedBox(height: 12),
          BrutalistButton(
            label: 'BACK',
            onPressed: widget.onBack,
            type: BrutalistButtonType.secondary,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
