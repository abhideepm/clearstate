import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/animated_counter.dart';
import '../../../shared/widgets/animated_stepper_button.dart';
import '../../../shared/widgets/brutalist_button.dart';

class CostPerDrinkStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CostPerDrinkStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<CostPerDrinkStep> createState() => _CostPerDrinkStepState();
}

class _CostPerDrinkStepState extends ConsumerState<CostPerDrinkStep> {
  double _cost = 8.0;

  void _increment() {
    HapticService.medium();
    setState(() => _cost += 1);
  }

  void _decrement() {
    if (_cost > 1) {
      HapticService.medium();
      setState(() => _cost -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            'AVERAGE COST\nPER DRINK?',
            style: ClearStateTypography.h1.copyWith(fontSize: 32, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'We\'ll calculate your savings',
            style: ClearStateTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedStepperButton(
                icon: Icons.remove,
                onTap: _decrement,
                enabled: _cost > 1,
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 120,
                child: AnimatedCounter(
                  value: _cost.toInt(),
                  style: ClearStateTypography.timerDisplay,
                ),
              ),
              const SizedBox(width: 24),
              AnimatedStepperButton(icon: Icons.add, onTap: _increment),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'PER DRINK',
            style: ClearStateTypography.timerLabel,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          BrutalistButton(
            label: 'START MY JOURNEY',
            onPressed: () {
              ref.read(onboardingProvider.notifier).setCostPerDrink(_cost);
              widget.onNext();
            },
            type: BrutalistButtonType.primary,
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
