import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../../../data/models/widget_config.dart';
import '../providers/widget_settings_provider.dart';

/// Bottom sheet for configuring the Battery widget.
///
/// Allows the user to select:
/// - Display mode (milestone, goal, daily)
/// - Goal days (when in goal mode)
class BatteryConfigSheet extends ConsumerStatefulWidget {
  const BatteryConfigSheet({super.key});

  @override
  ConsumerState<BatteryConfigSheet> createState() => _BatteryConfigSheetState();
}

class _BatteryConfigSheetState extends ConsumerState<BatteryConfigSheet> {
  late BatteryDisplayMode _selectedMode;
  late int _goalDays;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final currentConfig = ref.read(widgetSettingsProvider).batteryConfig;
    _selectedMode = currentConfig?.displayMode ?? BatteryDisplayMode.milestone;
    _goalDays = currentConfig?.goalDays ?? 30;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: ClearStateColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ClearStateColors.borderDark,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'BATTERY WIDGET',
              style: ClearStateTypography.h2.copyWith(
                color: ClearStateColors.dawnCoral,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what the progress ring displays',
              style: ClearStateTypography.caption.copyWith(
                color: ClearStateColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Display Mode selection
            Text(
              'DISPLAY MODE',
              style: ClearStateTypography.caption.copyWith(
                color: ClearStateColors.textSecondaryDark,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            _ModeOption(
              mode: BatteryDisplayMode.milestone,
              title: 'Milestone Progress',
              description: 'Progress toward next recovery milestone',
              isSelected: _selectedMode == BatteryDisplayMode.milestone,
              onTap: () => _selectMode(BatteryDisplayMode.milestone),
            ),
            const SizedBox(height: 8),
            _ModeOption(
              mode: BatteryDisplayMode.goal,
              title: 'Goal Progress',
              description: 'Percentage of your custom goal completed',
              isSelected: _selectedMode == BatteryDisplayMode.goal,
              onTap: () => _selectMode(BatteryDisplayMode.goal),
            ),
            const SizedBox(height: 8),
            _ModeOption(
              mode: BatteryDisplayMode.daily,
              title: 'Daily Progress',
              description: 'Percentage of current day completed sober',
              isSelected: _selectedMode == BatteryDisplayMode.daily,
              onTap: () => _selectMode(BatteryDisplayMode.daily),
            ),

            // Goal days slider (only shown in goal mode)
            if (_selectedMode == BatteryDisplayMode.goal) ...[
              const SizedBox(height: 24),
              _GoalDaysSlider(
                value: _goalDays,
                onChanged: (value) {
                  HapticService.light();
                  setState(() => _goalDays = value);
                },
              ),
            ],

            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: ClearStateColors.dawnCoral,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ClearStateColors.darkBackground,
                      ),
                    )
                  : Text(
                      'SAVE CONFIGURATION',
                      style: ClearStateTypography.button.copyWith(
                        color: ClearStateColors.darkBackground,
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // Cancel
            TextButton(
              onPressed: () {
                HapticService.light();
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: ClearStateTypography.button.copyWith(
                  color: ClearStateColors.textSecondaryDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _selectMode(BatteryDisplayMode mode) {
    HapticService.light();
    setState(() => _selectedMode = mode);
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    HapticService.medium();

    await ref
        .read(widgetSettingsProvider.notifier)
        .saveBatteryConfig(mode: _selectedMode, goalDays: _goalDays);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

/// Radio option for display mode selection.
class _ModeOption extends StatelessWidget {
  final BatteryDisplayMode mode;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.mode,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? ClearStateColors.dawnCoral.withAlpha((0.1 * 255).round())
            : ClearStateColors.darkBackground,
        border: Border.all(
          color: isSelected ? ClearStateColors.dawnCoral : ClearStateColors.borderDark,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? ClearStateColors.dawnCoral
                          : ClearStateColors.borderDark,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: ClearStateColors.dawnCoral,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ClearStateTypography.body.copyWith(
                          color: isSelected
                              ? ClearStateColors.textPrimaryDark
                              : ClearStateColors.textSecondaryDark,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: ClearStateTypography.caption.copyWith(
                          color: ClearStateColors.textSecondaryDark,
                        ),
                      ),
                    ],
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

/// Slider for selecting goal days.
class _GoalDaysSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _GoalDaysSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'GOAL DAYS',
              style: ClearStateTypography.caption.copyWith(
                color: ClearStateColors.textSecondaryDark,
                letterSpacing: 2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ClearStateColors.dawnCoral.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$value DAYS',
                style: ClearStateTypography.statNumber.copyWith(
                  fontSize: 16,
                  color: ClearStateColors.dawnCoral,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: ClearStateColors.dawnCoral,
            inactiveTrackColor: ClearStateColors.borderDark,
            thumbColor: ClearStateColors.dawnCoral,
            overlayColor: ClearStateColors.dawnCoral.withAlpha(
              (0.2 * 255).round(),
            ),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 7,
            max: 365,
            divisions: 358,
            onChanged: (val) => onChanged(val.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '7 days',
              style: ClearStateTypography.caption.copyWith(
                color: ClearStateColors.borderDark,
                fontSize: 10,
              ),
            ),
            Text(
              '365 days',
              style: ClearStateTypography.caption.copyWith(
                color: ClearStateColors.borderDark,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
