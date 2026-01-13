import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../onboarding_provider.dart';

class CostPerDrinkStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const CostPerDrinkStep({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<CostPerDrinkStep> createState() => _CostPerDrinkStepState();
}

class _CostPerDrinkStepState extends ConsumerState<CostPerDrinkStep> {
  double _cost = 8.0;
  
  void _increment() {
    HapticFeedback.selectionClick();
    setState(() => _cost += 1);
  }
  
  void _decrement() {
    if (_cost > 1) {
      HapticFeedback.selectionClick();
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
            style: ClearStateTypography.h1.copyWith(
              fontSize: 32,
              height: 1.2,
            ),
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
              _StepperButton(icon: Icons.remove, onTap: _decrement),
              const SizedBox(width: 24),
              SizedBox(
                width: 120,
                child: Text(
                  '\$${_cost.toStringAsFixed(0)}',
                  style: ClearStateTypography.timerDisplay,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 24),
              _StepperButton(icon: Icons.add, onTap: _increment),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'PER DRINK',
            style: ClearStateTypography.timerLabel,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              ref.read(onboardingProvider.notifier).setCostPerDrink(_cost);
              widget.onNext();
            },
            child: const Text('START MY JOURNEY'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onBack,
            child: Text('BACK', style: ClearStateTypography.button.copyWith(color: ClearStateColors.smoke)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _StepperButton({required this.icon, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: ClearStateColors.charcoal,
          border: Border.all(color: ClearStateColors.ash),
        ),
        child: Icon(icon, color: ClearStateColors.bone),
      ),
    );
  }
}
