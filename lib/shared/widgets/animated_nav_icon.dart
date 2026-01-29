import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../core/services/haptic_service.dart';

class AnimatedNavIcon extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String? label;
  final bool isActive; // Matches app.dart usage
  final bool isSelected; // Keep for backward compat if needed (aliased)
  final VoidCallback onTap;
  final double size;

  const AnimatedNavIcon({
    super.key,
    required this.icon,
    this.activeIcon,
    this.label,
    this.isActive = false,
    bool? isSelected,
    required this.onTap,
    this.size = 24,
  }) : isSelected = isSelected ?? isActive;

  @override
  State<AnimatedNavIcon> createState() => _AnimatedNavIconState();
}

class _AnimatedNavIconState extends State<AnimatedNavIcon>
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

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
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
    final theme = Theme.of(context);
    final activeColor =
        theme.bottomNavigationBarTheme.selectedItemColor ??
        theme.colorScheme.primary;
    final inactiveColor =
        theme.bottomNavigationBarTheme.unselectedItemColor ??
        TrueStateColors.textSecondaryDark;

    final effectiveIcon = (widget.isActive && widget.activeIcon != null)
        ? widget.activeIcon!
        : widget.icon;

    final iconWidget = _buildIcon(effectiveIcon, activeColor, inactiveColor);

    if (widget.label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(height: 4),
          Text(
            widget.label!,
            style: TrueStateTypography.caption.copyWith(
              color: widget.isActive ? activeColor : inactiveColor,
              fontSize: 10,
              fontStyle: FontStyle.normal,
            ),
          ),
        ],
      );
    }

    return iconWidget;
  }

  Widget _buildIcon(IconData iconData, Color activeColor, Color inactiveColor) {
    if (TrueStateMotion.reduceMotion) {
      return Icon(
        iconData,
        color: widget.isActive ? activeColor : inactiveColor,
        size: widget.size,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: IconButton(
        onPressed: widget.onTap,
        icon: Icon(
          iconData,
          color: widget.isActive ? activeColor : inactiveColor,
          size: widget.size,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

class AnimatedNavIconCustom extends StatefulWidget {
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedNavIconCustom({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AnimatedNavIconCustom> createState() => _AnimatedNavIconCustomState();
}

class _AnimatedNavIconCustomState extends State<AnimatedNavIconCustom>
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

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedNavIconCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isSelected && widget.isSelected) {
      HapticService.light();
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
    if (TrueStateMotion.reduceMotion) {
      return GestureDetector(onTap: widget.onTap, child: widget.icon);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: widget.icon,
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedNavIconCustom(
              icon: icon,
              isSelected: isSelected,
              onTap: onTap,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TrueStateTypography.caption.copyWith(
                color: isSelected
                    ? TrueStateColors.dawnCoral
                    : TrueStateColors.textSecondaryDark,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
