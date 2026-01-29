import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/motion.dart';
import '../../core/services/haptic_service.dart';

class AnimatedStepperButton extends ConsumerStatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final double size;

  const AnimatedStepperButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.size = 48,
  });

  @override
  ConsumerState<AnimatedStepperButton> createState() =>
      _AnimatedStepperButtonState();
}

class _AnimatedStepperButtonState extends ConsumerState<AnimatedStepperButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TrueStateMotion.duration(const Duration(milliseconds: 100)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _colorAnimation = ColorTween(
      begin: TrueStateColors.darkSurface,
      end: TrueStateColors.darkElevated,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
    HapticService.medium();
    widget.onTap();
    _controller
      ..reset()
      ..forward().then((_) {
        if (mounted) {
          _controller.reverse();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              border: Border.all(
                color: widget.enabled
                    ? TrueStateColors.borderDark
                    : TrueStateColors.borderDark.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.enabled ? _handleTap : null,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: widget.enabled
                        ? TrueStateColors.textPrimaryDark
                        : TrueStateColors.textSecondaryDark.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StepperButtonRow extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoPrevious;
  final bool canGoNext;
  final IconData previousIcon;
  final IconData nextIcon;

  const StepperButtonRow({
    super.key,
    required this.onPrevious,
    required this.onNext,
    this.canGoPrevious = true,
    this.canGoNext = true,
    this.previousIcon = Icons.chevron_left,
    this.nextIcon = Icons.chevron_right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedStepperButton(
          icon: previousIcon,
          onTap: onPrevious,
          enabled: canGoPrevious,
        ),
        AnimatedStepperButton(
          icon: nextIcon,
          onTap: onNext,
          enabled: canGoNext,
        ),
      ],
    );
  }
}
