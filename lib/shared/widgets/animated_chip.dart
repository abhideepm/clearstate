import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';

class AnimatedChip extends ConsumerStatefulWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedChip({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  ConsumerState<AnimatedChip> createState() => _AnimatedChipState();
}

class _AnimatedChipState extends ConsumerState<AnimatedChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TrueStateMotion.duration(const Duration(milliseconds: 200)),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(AnimatedChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected && widget.isSelected) {
      _controller
        ..reset()
        ..forward();
    } else if (!widget.isSelected &&
        _controller.status == AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;

    return GestureDetector(
      onTap: () {
        HapticService.selection();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? accentColor
                : TrueStateColors.darkSurface,
            border: Border.all(
              color: widget.isSelected
                  ? accentColor
                  : TrueStateColors.borderDark,
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TrueStateTypography.button.copyWith(
              color: widget.isSelected
                  ? TrueStateColors.darkBackground
                  : TrueStateColors.textPrimaryDark,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
