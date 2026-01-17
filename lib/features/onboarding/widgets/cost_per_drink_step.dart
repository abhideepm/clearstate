import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/constants/currencies.dart';
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
  String _currencyCode = 'USD';

  @override
  void initState() {
    super.initState();
    _currencyCode = ref.read(onboardingProvider).currency;
  }

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

  void _changeCurrency() async {
    HapticService.light();
    final selected = await showDialog<String>(
      context: context,
      builder: (context) =>
          _CurrencySelectionDialog(currentCode: _currencyCode),
    );

    if (selected != null) {
      setState(() => _currencyCode = selected);
      ref.read(onboardingProvider.notifier).setCurrency(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = Currency.currencies
        .firstWhere(
          (c) => c.code == _currencyCode,
          orElse: () => Currency.currencies.first,
        )
        .symbol;

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
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currencySymbol,
                      style: ClearStateTypography.timerDisplay.copyWith(
                        color: ClearStateColors.signal,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: AnimatedCounter(
                        value: _cost.toInt(),
                        style: ClearStateTypography.timerDisplay,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              AnimatedStepperButton(icon: Icons.add, onTap: _increment),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _changeCurrency,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: ClearStateColors.ash),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CURRENCY: $_currencyCode',
                    style: ClearStateTypography.caption.copyWith(
                      color: ClearStateColors.smoke,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: ClearStateColors.smoke,
                    size: 16,
                  ),
                ],
              ),
            ),
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

class _CurrencySelectionDialog extends StatelessWidget {
  final String currentCode;

  const _CurrencySelectionDialog({required this.currentCode});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ClearStateColors.charcoal,
          border: Border.all(color: ClearStateColors.ash),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('SELECT CURRENCY', style: ClearStateTypography.h3),
            ),
            Container(height: 1, color: ClearStateColors.ash),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: Currency.currencies.length,
                itemBuilder: (context, index) {
                  final currency = Currency.currencies[index];
                  final isSelected = currency.code == currentCode;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticService.selection();
                        Navigator.of(context).pop(currency.code);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        color: isSelected
                            ? ClearStateColors.ash.withValues(alpha: 0.1)
                            : null,
                        child: Row(
                          children: [
                            Text(
                              currency.symbol,
                              style: ClearStateTypography.h3.copyWith(
                                color: isSelected
                                    ? ClearStateColors.signal
                                    : ClearStateColors.bone,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '${currency.name} (${currency.code})',
                                style: ClearStateTypography.body.copyWith(
                                  color: isSelected
                                      ? ClearStateColors.signal
                                      : ClearStateColors.smoke,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: ClearStateColors.signal,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(height: 1, color: ClearStateColors.ash),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'CANCEL',
                    style: ClearStateTypography.button.copyWith(
                      color: ClearStateColors.smoke,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
