import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';

class AnimatedTabSwitcher extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<BottomNavigationBarItem> items;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final Color? backgroundColor;
  final double? elevation;

  const AnimatedTabSwitcher({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.items,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: TrueStateColors.borderDark, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          HapticService.light();
          onIndexChanged(index);
        },
        items: items,
        selectedItemColor: selectedItemColor ?? accentColor,
        unselectedItemColor: unselectedItemColor ?? TrueStateColors.textSecondaryDark,
        backgroundColor: backgroundColor ?? TrueStateColors.darkBackground,
        elevation: elevation,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class AnimatedNavIcon extends ConsumerStatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final double size;

  const AnimatedNavIcon({
    super.key,
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.size = 24,
  });

  @override
  ConsumerState<AnimatedNavIcon> createState() => _AnimatedNavIconState();
}

class _AnimatedNavIconState extends ConsumerState<AnimatedNavIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TrueStateMotion.duration(const Duration(milliseconds: 300)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(AnimatedNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
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
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;

    return GestureDetector(
      onTap: () {
        HapticService.light();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotateAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.isActive
                  ? (widget.activeIcon ?? widget.icon)
                  : widget.icon,
              size: widget.size,
              color: widget.isActive ? accentColor : TrueStateColors.textSecondaryDark,
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TrueStateTypography.caption.copyWith(
                fontSize: 10,
                color: widget.isActive ? accentColor : TrueStateColors.textSecondaryDark,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
