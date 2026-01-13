import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../onboarding_provider.dart';

class LastDrinkStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const LastDrinkStep({super.key, required this.onNext});

  @override
  ConsumerState<LastDrinkStep> createState() => _LastDrinkStepState();
}

class _LastDrinkStepState extends ConsumerState<LastDrinkStep> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ClearStateColors.signal,
              surface: ClearStateColors.charcoal,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      ref.read(onboardingProvider.notifier).setLastDrinkDate(picked);
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
            'WHEN WAS YOUR\nLAST DRINK?',
            style: ClearStateTypography.h1.copyWith(fontSize: 32, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'This is where your journey begins',
            style: ClearStateTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: ClearStateColors.charcoal,
                border: Border.all(color: ClearStateColors.ash),
              ),
              child: Column(
                children: [
                  Text(
                    '${_selectedDate.day}',
                    style: ClearStateTypography.timerDisplay.copyWith(
                      fontSize: 64,
                    ),
                  ),
                  Text(
                    '${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                    style: ClearStateTypography.statLabel,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'TAP TO CHANGE',
            style: ClearStateTypography.caption.copyWith(
              color: ClearStateColors.smoke,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(onboardingProvider.notifier)
                  .setLastDrinkDate(_selectedDate);
              widget.onNext();
            },
            child: const Text('CONTINUE'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }
}
