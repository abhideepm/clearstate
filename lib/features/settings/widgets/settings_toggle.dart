import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';

/// A reusable toggle row for settings with label and switch.
class SettingsToggle extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ClearStateColors.charcoal,
        border: Border.all(color: ClearStateColors.ash, width: 1),
        borderRadius: BorderRadius.circular(2),
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
          borderRadius: BorderRadius.circular(2),
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
                        style: ClearStateTypography.body.copyWith(
                          color: enabled
                              ? ClearStateColors.bone
                              : ClearStateColors.smoke,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: ClearStateTypography.caption.copyWith(
                            color: ClearStateColors.smoke,
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
class _CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _CustomSwitch({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final primaryColor = Theme.of(context).primaryColor;

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
          color: value ? primaryColor : ClearStateColors.graphite,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: value ? primaryColor : ClearStateColors.ash,
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
              color: enabled ? ClearStateColors.bone : ClearStateColors.smoke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
