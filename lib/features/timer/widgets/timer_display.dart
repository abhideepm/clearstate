import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../timer_provider.dart';
import '../../../shared/widgets/animated_counter.dart';

class TimerDisplay extends ConsumerStatefulWidget {
  const TimerDisplay({super.key});

  @override
  ConsumerState<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends ConsumerState<TimerDisplay> {
  int _previousSeconds = 0;

  @override
  void didUpdateWidget(TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final components = ref.read(timerComponentsProvider);
    if (components.seconds != _previousSeconds) {
      _previousSeconds = components.seconds;
    }
  }

  @override
  Widget build(BuildContext context) {
    final components = ref.watch(timerComponentsProvider);
    final themeState = ref.watch(themeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (components.years > 0) ...[
              _TimerUnit(value: components.years, label: 'Years'),
              const SizedBox(width: 16),
            ],
            if (components.years > 0 || components.months > 0) ...[
              _TimerUnit(value: components.months, label: 'Months'),
              const SizedBox(width: 16),
            ],
            _TimerUnit(value: components.days, label: 'Days'),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SmallTimerUnit(value: components.hours, label: 'h'),
            Text(
              ' : ',
              style: ClearStateTypography.statNumber.copyWith(
                color: themeState.textSecondary,
              ),
            ),
            _SmallTimerUnit(value: components.minutes, label: 'm'),
            Text(
              ' : ',
              style: ClearStateTypography.statNumber.copyWith(
                color: themeState.textSecondary,
              ),
            ),
            _AnimatedSecondsUnit(value: components.seconds),
          ],
        ),
      ],
    );
  }
}

class _AnimatedSecondsUnit extends StatefulWidget {
  final int value;

  const _AnimatedSecondsUnit({required this.value});

  @override
  State<_AnimatedSecondsUnit> createState() => _AnimatedSecondsUnitState();
}

class _AnimatedSecondsUnitState extends State<_AnimatedSecondsUnit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  @override
  void didUpdateWidget(_AnimatedSecondsUnit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _previousValue) {
      _previousValue = widget.value;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: child,
        );
      },
      child: _SmallTimerUnit(value: widget.value, label: 's'),
    );
  }
}

class _TimerUnit extends ConsumerWidget {
  final int value;
  final String label;

  const _TimerUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedCounter(
          value: value, 
          style: ClearStateTypography.timerDisplay.copyWith(
            color: themeState.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: ClearStateTypography.timerLabel.copyWith(
            color: themeState.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SmallTimerUnit extends ConsumerWidget {
  final int value;
  final String label;

  const _SmallTimerUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedCounter(
          value: value, 
          style: ClearStateTypography.statNumber.copyWith(
            color: themeState.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: ClearStateTypography.statLabel.copyWith(
            color: themeState.textSecondary,
          ),
        ),
      ],
    );
  }
}
