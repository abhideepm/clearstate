import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';

class AnimatedCounter extends ConsumerStatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final bool morphDigits;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 300),
    this.morphDigits = false,
  });

  @override
  ConsumerState<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends ConsumerState<AnimatedCounter> {
  int _previousValue = 0;

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.style ?? ClearStateTypography.timerDisplay;

    if (ClearStateMotion.reduceMotion) {
      return Text(widget.value.toString(), style: textStyle);
    }

    if (widget.morphDigits) {
      return _MorphingDigitsCounter(
        currentValue: widget.value,
        previousValue: _previousValue,
        style: textStyle,
        duration: widget.duration,
      );
    }

    return _SlidingDigitCounter(
      currentValue: widget.value,
      previousValue: _previousValue,
      style: textStyle,
      duration: widget.duration,
    );
  }
}

class _SlidingDigitCounter extends StatefulWidget {
  final int currentValue;
  final int previousValue;
  final TextStyle style;
  final Duration duration;

  const _SlidingDigitCounter({
    required this.currentValue,
    required this.previousValue,
    required this.style,
    required this.duration,
  });

  @override
  State<_SlidingDigitCounter> createState() => __SlidingDigitCounterState();
}

class __SlidingDigitCounterState extends State<_SlidingDigitCounter> {
  @override
  Widget build(BuildContext context) {
    final currentStr = widget.currentValue.toString();
    final previousStr = widget.previousValue.toString();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(currentStr.length, (index) {
        final currentDigit = index < currentStr.length ? currentStr[index] : '';
        final previousDigit = index < previousStr.length
            ? previousStr[index]
            : '';

        if (currentDigit == previousDigit || previousDigit.isEmpty) {
          return _SingleDigit(digit: currentDigit, style: widget.style);
        }

        return AnimatedSwitcher(
          duration: widget.duration,
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _SingleDigit(
            key: ValueKey<String>('$index-${widget.currentValue}'),
            digit: currentDigit,
            style: widget.style,
          ),
        );
      }),
    );
  }
}

class _MorphingDigitsCounter extends StatefulWidget {
  final int currentValue;
  final int previousValue;
  final TextStyle style;
  final Duration duration;

  const _MorphingDigitsCounter({
    required this.currentValue,
    required this.previousValue,
    required this.style,
    required this.duration,
  });

  @override
  State<_MorphingDigitsCounter> createState() => __MorphingDigitsCounterState();
}

class __MorphingDigitsCounterState extends State<_MorphingDigitsCounter> {
  @override
  Widget build(BuildContext context) {
    final maxLength = widget.currentValue.toString().length;
    final previousMaxLength = widget.previousValue.toString().length;
    final maxDigits = maxLength > previousMaxLength
        ? maxLength
        : previousMaxLength;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxDigits, (index) {
        final currentDigit = index < widget.currentValue.toString().length
            ? widget.currentValue.toString()[index]
            : '';
        final previousDigit = index < widget.previousValue.toString().length
            ? widget.previousValue.toString()[index]
            : '';

        return _MorphingDigit(
          currentDigit: currentDigit,
          previousDigit: previousDigit,
          style: widget.style,
          duration: widget.duration,
          index: index,
        );
      }),
    );
  }
}

class _MorphingDigit extends StatefulWidget {
  final String currentDigit;
  final String previousDigit;
  final TextStyle style;
  final Duration duration;
  final int index;

  const _MorphingDigit({
    required this.currentDigit,
    required this.previousDigit,
    required this.style,
    required this.duration,
    required this.index,
  });

  @override
  State<_MorphingDigit> createState() => __MorphingDigitState();
}

class __MorphingDigitState extends State<_MorphingDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
        milliseconds: (widget.duration.inMilliseconds * 0.6).round(),
      ),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 70,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void didUpdateWidget(_MorphingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentDigit != oldWidget.currentDigit) {
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
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Text(widget.currentDigit, style: widget.style),
    );
  }
}

class _SingleDigit extends StatelessWidget {
  final String digit;
  final TextStyle style;

  const _SingleDigit({required this.digit, required this.style, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(digit, style: style, key: key);
  }
}
