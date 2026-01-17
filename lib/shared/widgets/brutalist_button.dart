import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';

enum BrutalistButtonType { primary, secondary }

class BrutalistButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final BrutalistButtonType type;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double? height;

  const BrutalistButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = BrutalistButtonType.primary,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
  });

  @override
  ConsumerState<BrutalistButton> createState() => _BrutalistButtonState();
}

class _BrutalistButtonState extends ConsumerState<BrutalistButton> {
  bool _isPressed = false;

  void _handlePressDown() {
    if (!widget.enabled || widget.isLoading) return;
    setState(() => _isPressed = true);
    HapticService.buttonDown();
  }

  void _handlePressUp() {
    if (!widget.enabled || widget.isLoading) return;
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (!widget.enabled || widget.isLoading) return;
    HapticService.medium();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.type == BrutalistButtonType.primary;
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;
    final accentColorLight = HSLColor.fromColor(accentColor)
        .withLightness(
          (HSLColor.fromColor(accentColor).lightness + 0.1).clamp(0.0, 1.0),
        )
        .toColor();

    return AnimatedContainer(
      duration: ClearStateMotion.duration(const Duration(milliseconds: 100)),
      curve: Curves.easeOut,
      width: widget.width,
      height: widget.height ?? 48,
      transform: Matrix4.diagonal3Values(
        _isPressed ? 0.95 : 1.0,
        _isPressed ? 0.95 : 1.0,
        1.0,
      ),
      decoration: BoxDecoration(
        color: isPrimary
            ? _isPressed
                  ? accentColorLight
                  : accentColor
            : Colors.transparent,
        border: Border.all(
          color: _isPressed
              ? isPrimary
                    ? accentColorLight
                    : ClearStateColors.smoke
              : ClearStateColors.ash,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled && !widget.isLoading ? _handleTap : null,
          onTapDown: (_) => _handlePressDown(),
          onTapUp: (_) => _handlePressUp(),
          onTapCancel: _handlePressUp,
          borderRadius: BorderRadius.circular(2),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ClearStateColors.void_,
                    ),
                  )
                : Text(
                    widget.label,
                    style: ClearStateTypography.button.copyWith(
                      color: isPrimary
                          ? ClearStateColors.void_
                          : ClearStateColors.smoke,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class BrutalistButtonIcon extends ConsumerStatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final BrutalistButtonType type;
  final bool isLoading;
  final bool enabled;
  final double size;

  const BrutalistButtonIcon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.type = BrutalistButtonType.primary,
    this.isLoading = false,
    this.enabled = true,
    this.size = 48,
  });

  @override
  ConsumerState<BrutalistButtonIcon> createState() =>
      _BrutalistButtonIconState();
}

class _BrutalistButtonIconState extends ConsumerState<BrutalistButtonIcon> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.type == BrutalistButtonType.primary;
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;
    final accentColorLight = HSLColor.fromColor(accentColor)
        .withLightness(
          (HSLColor.fromColor(accentColor).lightness + 0.1).clamp(0.0, 1.0),
        )
        .toColor();

    return AnimatedContainer(
      duration: ClearStateMotion.duration(const Duration(milliseconds: 100)),
      curve: Curves.easeOut,
      width: widget.size,
      height: widget.size,
      transform: Matrix4.diagonal3Values(
        _isPressed ? 0.95 : 1.0,
        _isPressed ? 0.95 : 1.0,
        1.0,
      ),
      decoration: BoxDecoration(
        color: isPrimary
            ? _isPressed
                  ? accentColorLight
                  : accentColor
            : Colors.transparent,
        border: Border.all(
          color: _isPressed
              ? isPrimary
                    ? accentColorLight
                    : ClearStateColors.smoke
              : ClearStateColors.ash,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled && !widget.isLoading
              ? () {
                  HapticService.medium();
                  widget.onPressed();
                }
              : null,
          onTapDown: (_) {
            if (widget.enabled && !widget.isLoading) {
              setState(() => _isPressed = true);
              HapticService.buttonDown();
            }
          },
          onTapUp: (_) {
            if (widget.enabled && !widget.isLoading) {
              setState(() => _isPressed = false);
            }
          },
          onTapCancel: () {
            if (widget.enabled && !widget.isLoading) {
              setState(() => _isPressed = false);
            }
          },
          borderRadius: BorderRadius.circular(2),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ClearStateColors.void_,
                    ),
                  )
                : Icon(
                    widget.icon,
                    color: isPrimary
                        ? ClearStateColors.void_
                        : ClearStateColors.smoke,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
