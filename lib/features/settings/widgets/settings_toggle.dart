import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/theme_provider.dart';

/// A reusable toggle row for settings with label and switch.
class SettingsToggle extends ConsumerWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const SettingsToggle({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    return Container(
      decoration: BoxDecoration(
        color: themeState.surface,
        border: Border.all(color: themeState.border, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticService.light();
                  onChanged(!value);
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TrueStateTypography.body.copyWith(
                          color: enabled
                              ? themeState.textPrimary
                              : themeState.textSecondary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TrueStateTypography.caption.copyWith(
                            color: themeState.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _CustomSwitch(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom switch widget matching app styling.
class _CustomSwitch extends ConsumerWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _CustomSwitch({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = onChanged != null;
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accentValue;

    return GestureDetector(
      onTap: enabled
          ? () {
              HapticService.light();
              onChanged!(!value);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: value ? accentColor : themeState.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? accentColor : themeState.border,
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: enabled
                  ? themeState.textPrimary
                  : themeState.textSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
