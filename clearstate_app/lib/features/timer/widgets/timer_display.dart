import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/colors.dart';
import '../timer_provider.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final components = ref.watch(timerComponentsProvider);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main timer row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (components.years > 0) ...[
              _TimerUnit(value: components.years, label: 'YRS'),
              const SizedBox(width: 16),
            ],
            if (components.years > 0 || components.months > 0) ...[
              _TimerUnit(value: components.months, label: 'MOS'),
              const SizedBox(width: 16),
            ],
            _TimerUnit(value: components.days, label: 'DAYS'),
          ],
        ),
        const SizedBox(height: 24),
        // Secondary timer (hours:minutes:seconds)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SmallTimerUnit(value: components.hours, label: 'H'),
            Text(' : ', style: ClearStateTypography.statNumber.copyWith(color: ClearStateColors.smoke)),
            _SmallTimerUnit(value: components.minutes, label: 'M'),
            Text(' : ', style: ClearStateTypography.statNumber.copyWith(color: ClearStateColors.smoke)),
            _SmallTimerUnit(value: components.seconds, label: 'S'),
          ],
        ),
      ],
    );
  }
}

class _TimerUnit extends StatelessWidget {
  final int value;
  final String label;
  
  const _TimerUnit({required this.value, required this.label});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: ClearStateTypography.timerDisplay,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: ClearStateTypography.timerLabel,
        ),
      ],
    );
  }
}

class _SmallTimerUnit extends StatelessWidget {
  final int value;
  final String label;
  
  const _SmallTimerUnit({required this.value, required this.label});
  
  @override
  Widget build(BuildContext context) {
    return Text(
      value.toString().padLeft(2, '0'),
      style: ClearStateTypography.statNumber,
    );
  }
}
