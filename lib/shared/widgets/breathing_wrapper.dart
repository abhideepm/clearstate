import 'package:flutter/material.dart';
import '../../core/theme/motion.dart';

/// Wrapper widget that applies a gentle breathing (pulsing) animation
/// to its child. Used for emphasis on important elements like the timer.
class BreathingWrapper extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;
  final bool enabled;

  const BreathingWrapper({
    super.key,
    required this.child,
    this.minScale = TrueStateMotion.breathMinScale,
    this.maxScale = TrueStateMotion.breathMaxScale,
    this.duration = TrueStateMotion.breathCycle,
    this.enabled = true,
  });

  @override
  State<BreathingWrapper> createState() => _BreathingWrapperState();
}

class _BreathingWrapperState extends State<BreathingWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: widget.minScale,
          end: widget.maxScale,
        ).chain(CurveTween(curve: TrueStateMotion.breathInCurve)),
        weight: 45,
      ),
      TweenSequenceItem(tween: ConstantTween(widget.maxScale), weight: 10),
      TweenSequenceItem(
        tween: Tween(
          begin: widget.maxScale,
          end: widget.minScale,
        ).chain(CurveTween(curve: TrueStateMotion.breathOutCurve)),
        weight: 45,
      ),
    ]).animate(_controller);

    _startAnimation();
  }

  void _startAnimation() {
    if (widget.enabled && !TrueStateMotion.reduceMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(BreathingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled && !TrueStateMotion.reduceMotion) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || TrueStateMotion.reduceMotion) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: widget.child,
    );
  }
}

/// Pulsing glow effect wrapper for milestone unlock animations
class GlowPulseWrapper extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final Duration duration;
  final bool enabled;

  const GlowPulseWrapper({
    super.key,
    required this.child,
    required this.glowColor,
    this.duration = const Duration(milliseconds: 2000),
    this.enabled = true,
  });

  @override
  State<GlowPulseWrapper> createState() => _GlowPulseWrapperState();
}

class _GlowPulseWrapperState extends State<GlowPulseWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _opacityAnimation =
        Tween<double>(
          begin: TrueStateMotion.glowMinOpacity,
          end: TrueStateMotion.glowMaxOpacity,
        ).animate(
          CurvedAnimation(parent: _controller, curve: TrueStateMotion.organic),
        );

    if (widget.enabled && !TrueStateMotion.reduceMotion) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || TrueStateMotion.reduceMotion) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(
                  alpha: _opacityAnimation.value,
                ),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
