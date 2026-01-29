import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';

enum ModernButtonType { primary, secondary, text }

/// Modern fintech-style button with soft shadows and rounded corners
class ModernButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final ModernButtonType type;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double? height;
  final IconData? icon;

  const ModernButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ModernButtonType.primary,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
    this.icon,
  });

  @override
  ConsumerState<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends ConsumerState<ModernButton> {
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
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;
    final isDark = themeState.isDarkMode;

    Color backgroundColor;
    Color foregroundColor;
    List<BoxShadow>? shadows;
    Border? border;

    switch (widget.type) {
      case ModernButtonType.primary:
        backgroundColor = accentColor;
        foregroundColor = TrueStateColors.textPrimaryLight;
        shadows = _isPressed
            ? null
            : [
                BoxShadow(
                  color: TrueStateColors.dawnCoral.withValues(alpha: 0.35),
                  offset: const Offset(0, 6),
                  blurRadius: 16,
                ),
              ];
        break;
      case ModernButtonType.secondary:
        backgroundColor = isDark
            ? TrueStateColors.darkCard
            : TrueStateColors.lightCard;
        foregroundColor = isDark
            ? TrueStateColors.textPrimaryDark
            : TrueStateColors.textPrimaryLight;
        border = Border.all(
          color: isDark
              ? TrueStateColors.borderDark
              : TrueStateColors.borderLight,
          width: 1,
        );
        break;
      case ModernButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = accentColor;
        break;
    }

    if (!widget.enabled) {
      backgroundColor = backgroundColor.withValues(alpha: 0.5);
      foregroundColor = foregroundColor.withValues(alpha: 0.5);
      shadows = null;
    }

    return AnimatedContainer(
      duration: TrueStateMotion.duration(const Duration(milliseconds: 150)),
      curve: Curves.easeOut,
      width: widget.width,
      height: widget.height ?? 56,
      transform: Matrix4.diagonal3Values(
        _isPressed ? 0.98 : 1.0,
        _isPressed ? 0.98 : 1.0,
        1.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled && !widget.isLoading ? _handleTap : null,
          onTapDown: (_) => _handlePressDown(),
          onTapUp: (_) => _handlePressUp(),
          onTapCancel: _handlePressUp,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: foregroundColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: foregroundColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TrueStateTypography.button.copyWith(
                          color: foregroundColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Modern icon button with soft styling
class ModernIconButton extends ConsumerStatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final ModernButtonType type;
  final bool isLoading;
  final bool enabled;
  final double size;

  const ModernIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.type = ModernButtonType.primary,
    this.isLoading = false,
    this.enabled = true,
    this.size = 48,
  });

  @override
  ConsumerState<ModernIconButton> createState() => _ModernIconButtonState();
}

class _ModernIconButtonState extends ConsumerState<ModernIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;
    final isDark = themeState.isDarkMode;

    Color backgroundColor;
    Color iconColor;

    switch (widget.type) {
      case ModernButtonType.primary:
        backgroundColor = accentColor;
        iconColor = TrueStateColors.textPrimaryLight;
        break;
      case ModernButtonType.secondary:
        backgroundColor = isDark
            ? TrueStateColors.darkCard
            : TrueStateColors.lightElevated;
        iconColor = isDark
            ? TrueStateColors.textPrimaryDark
            : TrueStateColors.textPrimaryLight;
        break;
      case ModernButtonType.text:
        backgroundColor = Colors.transparent;
        iconColor = accentColor;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: widget.size,
      height: widget.size,
      transform: Matrix4.diagonal3Values(
        _isPressed ? 0.95 : 1.0,
        _isPressed ? 0.95 : 1.0,
        1.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.size / 2),
        boxShadow: widget.type == ModernButtonType.primary && !_isPressed
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ]
            : null,
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
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: iconColor,
                    ),
                  )
                : Icon(widget.icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}
