import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/animated_counter.dart';
import '../../../shared/widgets/animated_stepper_button.dart';

class DrinksPerWeekStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DrinksPerWeekStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<DrinksPerWeekStep> createState() => _DrinksPerWeekStepState();
}

class _DrinksPerWeekStepState extends ConsumerState<DrinksPerWeekStep> {
  int _count = 10;

  void _increment() {
    HapticService.medium();
    setState(() => _count++);
  }

  void _decrement() {
    if (_count > 1) {
      HapticService.medium();
      setState(() => _count--);
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
            'HOW MANY DRINKS\nPER WEEK?',
            style: ClearStateTypography.h1.copyWith(fontSize: 32, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'On average, before you decided to stop',
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
                enabled: _count > 1,
              ),
              const SizedBox(width: 32),
              SizedBox(
                width: 100,
                child: Center(
                  child: AnimatedCounter(
                    value: _count,
                    style: ClearStateTypography.timerDisplay,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              AnimatedStepperButton(icon: Icons.add, onTap: _increment),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'DRINKS',
            style: ClearStateTypography.timerLabel,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          BrutalistButton(
            label: 'CONTINUE',
            onPressed: () {
              ref.read(onboardingProvider.notifier).setDrinksPerWeek(_count);
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
