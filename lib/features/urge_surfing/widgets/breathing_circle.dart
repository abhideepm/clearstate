import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../urge_surfing_provider.dart';

/// Animated breathing circle that expands and contracts
/// based on the current breathing phase.
class BreathingCircle extends StatefulWidget {
  final BreathingPhase phase;
  final bool isActive;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.isActive,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  static const double _minSize = 100.0;
  static const double _maxSize = 200.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _updateAnimation();
  }

  @override
  void didUpdateWidget(BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase ||
        oldWidget.isActive != widget.isActive) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (!widget.isActive) {
      _controller.stop();
      _controller.value = 0;
      _scaleAnimation = Tween<double>(
        begin: _minSize,
        end: _minSize,
      ).animate(_controller);
      return;
    }

    double targetSize;
    Duration duration;
    Curve curve;

    switch (widget.phase) {
      case BreathingPhase.inhale:
        // Expand from min to max over 4 seconds
        targetSize = _maxSize;
        duration = const Duration(seconds: 4);
        curve = Curves.easeInOut;
        break;
      case BreathingPhase.hold:
        // Stay at max for 1 second
        targetSize = _maxSize;
        duration = const Duration(seconds: 1);
        curve = Curves.linear;
        break;
      case BreathingPhase.exhale:
        // Contract from max to min over 5 seconds
        targetSize = _minSize;
        duration = const Duration(seconds: 5);
        curve = Curves.easeInOut;
        break;
    }

    // Get current size
    double currentSize = _minSize;
    if (_controller.isAnimating || _controller.value > 0) {
      currentSize = _scaleAnimation.value;
    } else if (widget.phase == BreathingPhase.hold ||
        widget.phase == BreathingPhase.exhale) {
      currentSize = _maxSize;
    }

    _scaleAnimation = Tween<double>(
      begin: currentSize,
      end: targetSize,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _controller.duration = duration;
    _controller.forward(from: 0);
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
        final size = widget.isActive ? _scaleAnimation.value : _minSize;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ClearStateColors.signal.withValues(alpha: 0.3),
            border: Border.all(color: ClearStateColors.signal, width: 3),
            boxShadow: [
              BoxShadow(
                color: ClearStateColors.signal.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: ClearStateColors.signal.withValues(alpha: 0.2),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
