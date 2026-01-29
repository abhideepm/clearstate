import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/bio_states.dart';
import '../../core/constants/hive_boxes.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/widget_data_service.dart';
import '../../core/services/widget_update_service.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/widget_config.dart';
import '../../shared/widgets/noise_background.dart';
import 'widgets/widget_preview_card.dart';
import 'widgets/widget_install_guide.dart';

/// Settings screen for configuring home screen widgets.
///
/// Displays preview cards for each widget type (Battery, Stoic, Bio-State)
/// that can be tapped to open configuration bottom sheets.
class WidgetSettingsScreen extends ConsumerStatefulWidget {
  const WidgetSettingsScreen({super.key});

  @override
  ConsumerState<WidgetSettingsScreen> createState() =>
      _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends ConsumerState<WidgetSettingsScreen> {
  late Box<WidgetConfig> _configBox;

  // Widget configurations
  WidgetConfig? _batteryConfig;
  WidgetConfig? _stoicConfig;
  WidgetConfig? _bioStateConfig;

  @override
  void initState() {
    super.initState();
    _configBox = Hive.box<WidgetConfig>(HiveBoxes.widgetConfigs);
    _loadConfigs();
  }

  void _loadConfigs() {
    setState(() {
      _batteryConfig =
          _configBox.get('battery') ??
          WidgetConfig(widgetType: 'battery', isEnabled: true);
      _stoicConfig =
          _configBox.get('stoic') ??
          WidgetConfig(widgetType: 'stoic', isEnabled: true);
      _bioStateConfig =
          _configBox.get('bioState') ??
          WidgetConfig(
            widgetType: 'bioState',
            bioStateMetricId: 'gaba',
            isEnabled: true,
          );
    });
  }

  Future<void> _saveConfig(String key, WidgetConfig config) async {
    await _configBox.put(key, config);
    await _updateWidgets();
  }

  Future<void> _updateWidgets() async {
    try {
      final widgetService = ref.read(widgetUpdateServiceProvider);
      final dataService = ref.read(widgetDataServiceProvider);

      final quote = dataService.getStoicQuote();
      final bioMetric = dataService.getBioStateMetric(
        _bioStateConfig?.bioStateMetricId ?? 'gaba',
      );

      final widgetData = WidgetData(
        batteryProgress: dataService.getBatteryProgress(
          _batteryConfig?.displayMode ?? BatteryDisplayMode.milestone,
          goalDays: _batteryConfig?.goalDays,
        ),
        streakDays: dataService.getCurrentStreak(),
        stoicQuote: quote.text,
        stoicAuthor: quote.author,
        bioStateLabel: bioMetric?.stealthLabel ?? 'Recovery',
        bioStateValue: dataService.getBioStateValue(
          _bioStateConfig?.bioStateMetricId ?? 'gaba',
        ),
      );

      await widgetService.updateAllWidgets(
        data: widgetData,
        batteryConfig: _batteryConfig,
        stoicConfig: _stoicConfig,
        bioStateConfig: _bioStateConfig,
      );
    } catch (e) {
      debugPrint('Error updating widgets: $e');
    }
  }

  /// Check if a widget type is configured.
  bool _isConfigured(WidgetType type) {
    switch (type) {
      case WidgetType.battery:
        return _batteryConfig?.isEnabled ?? false;
      case WidgetType.stoic:
        return _stoicConfig?.isEnabled ?? false;
      case WidgetType.bioState:
        return (_bioStateConfig?.isEnabled ?? false) &&
            _bioStateConfig?.bioStateMetricId != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrueStateColors.darkBackground,
      body: DawnBackground(
        opacity: 0.025,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Back button row
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            HapticService.light();
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: TrueStateColors.textPrimaryDark,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'STEALTH WIDGETS',
                      style: TrueStateTypography.timerLabel.copyWith(
                        fontSize: 14,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Premium badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: TrueStateColors.dawnCoral.withAlpha(
                          (0.15 * 255).round(),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TrueStateColors.dawnCoral.withAlpha(
                            (0.3 * 255).round(),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: TrueStateColors.dawnCoral,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PREMIUM FEATURE',
                            style: TrueStateTypography.caption.copyWith(
                              color: TrueStateColors.dawnCoral,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Description
                    Text(
                      'Add widgets to your home screen that blend in seamlessly. '
                      'Only you will know what they really track.',
                      style: TrueStateTypography.body.copyWith(
                        color: TrueStateColors.textSecondaryDark,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Widget Cards Section
                    _SectionHeader(title: 'AVAILABLE WIDGETS'),
                    const SizedBox(height: 12),

                    // Battery Widget Card
                    WidgetPreviewCard(
                      widgetType: WidgetType.battery,
                      title: 'Battery Widget',
                      description: 'Progress ring showing your sobriety streak',
                      isConfigured: _isConfigured(WidgetType.battery),
                      onTap: () => _showBatteryConfigSheet(context),
                    ),
                    const SizedBox(height: 12),

                    // Stoic Widget Card
                    WidgetPreviewCard(
                      widgetType: WidgetType.stoic,
                      title: 'Stoic Widget',
                      description: 'Daily quotes to inspire your journey',
                      isConfigured: _isConfigured(WidgetType.stoic),
                      onTap: () => _showStoicConfigSheet(context),
                    ),
                    const SizedBox(height: 12),

                    // Bio-State Widget Card
                    WidgetPreviewCard(
                      widgetType: WidgetType.bioState,
                      title: 'Bio-State Widget',
                      description:
                          'Track your recovery metrics in stealth mode',
                      isConfigured: _isConfigured(WidgetType.bioState),
                      onTap: () => _showBioStateConfigSheet(context),
                    ),

                    const SizedBox(height: 32),

                    // Help Section
                    _SectionHeader(title: 'GETTING STARTED'),
                    const SizedBox(height: 12),
                    const WidgetInstallGuide(),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show the battery widget configuration sheet.
  void _showBatteryConfigSheet(BuildContext context) {
    HapticService.medium();
    showModalBottomSheet(
      context: context,
      backgroundColor: TrueStateColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (context) => _BatteryConfigSheet(
        currentConfig: _batteryConfig,
        onSave: (mode, goalDays) async {
          final config = _batteryConfig ?? WidgetConfig(widgetType: 'battery');
          config.batteryMode = mode.name;
          config.goalDays = goalDays;
          config.isEnabled = true;
          setState(() => _batteryConfig = config);
          await _saveConfig('battery', config);
        },
      ),
    );
  }

  /// Show stoic widget confirmation.
  void _showStoicConfigSheet(BuildContext context) {
    HapticService.medium();
    showModalBottomSheet(
      context: context,
      backgroundColor: TrueStateColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (context) => _StoicConfigSheet(
        onSave: () async {
          final config = _stoicConfig ?? WidgetConfig(widgetType: 'stoic');
          config.isEnabled = true;
          setState(() => _stoicConfig = config);
          await _saveConfig('stoic', config);
        },
      ),
    );
  }

  /// Show the bio-state widget configuration sheet.
  void _showBioStateConfigSheet(BuildContext context) {
    HapticService.medium();
    showModalBottomSheet(
      context: context,
      backgroundColor: TrueStateColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (context) => _BioStateConfigSheet(
        currentMetricId: _bioStateConfig?.bioStateMetricId,
        onSave: (metricId) async {
          final config =
              _bioStateConfig ?? WidgetConfig(widgetType: 'bioState');
          config.bioStateMetricId = metricId;
          config.isEnabled = true;
          setState(() => _bioStateConfig = config);
          await _saveConfig('bioState', config);
        },
      ),
    );
  }
}

/// Section header text.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TrueStateTypography.timerLabel.copyWith(
        color: TrueStateColors.textSecondaryDark,
        letterSpacing: 3,
      ),
    );
  }
}

/// Battery widget configuration sheet.
class _BatteryConfigSheet extends StatefulWidget {
  final WidgetConfig? currentConfig;
  final Future<void> Function(BatteryDisplayMode mode, int goalDays) onSave;

  const _BatteryConfigSheet({this.currentConfig, required this.onSave});

  @override
  State<_BatteryConfigSheet> createState() => _BatteryConfigSheetState();
}

class _BatteryConfigSheetState extends State<_BatteryConfigSheet> {
  late BatteryDisplayMode _selectedMode;
  late int _goalDays;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMode =
        widget.currentConfig?.displayMode ?? BatteryDisplayMode.milestone;
    _goalDays = widget.currentConfig?.goalDays ?? 30;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
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
                  color: TrueStateColors.borderDark,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'BATTERY WIDGET',
              style: TrueStateTypography.h2.copyWith(
                color: TrueStateColors.dawnCoral,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what the progress ring displays',
              style: TrueStateTypography.caption.copyWith(
                color: TrueStateColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Display Mode selection
            Text(
              'DISPLAY MODE',
              style: TrueStateTypography.caption.copyWith(
                color: TrueStateColors.textSecondaryDark,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            _ModeOption(
              title: 'Milestone Progress',
              description: 'Progress toward next recovery milestone',
              isSelected: _selectedMode == BatteryDisplayMode.milestone,
              onTap: () => _selectMode(BatteryDisplayMode.milestone),
            ),
            const SizedBox(height: 8),
            _ModeOption(
              title: 'Goal Progress',
              description: 'Percentage of your custom goal completed',
              isSelected: _selectedMode == BatteryDisplayMode.goal,
              onTap: () => _selectMode(BatteryDisplayMode.goal),
            ),
            const SizedBox(height: 8),
            _ModeOption(
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
                backgroundColor: TrueStateColors.dawnCoral,
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
                        color: TrueStateColors.darkBackground,
                      ),
                    )
                  : Text(
                      'SAVE CONFIGURATION',
                      style: TrueStateTypography.button.copyWith(
                        color: TrueStateColors.darkBackground,
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
                style: TrueStateTypography.button.copyWith(
                  color: TrueStateColors.textSecondaryDark,
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

    await widget.onSave(_selectedMode, _goalDays);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

/// Radio option for display mode selection.
class _ModeOption extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeOption({
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
            ? TrueStateColors.dawnCoral.withAlpha((0.1 * 255).round())
            : TrueStateColors.darkBackground,
        border: Border.all(
          color: isSelected
              ? TrueStateColors.dawnCoral
              : TrueStateColors.borderDark,
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
                          ? TrueStateColors.dawnCoral
                          : TrueStateColors.borderDark,
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
                              color: TrueStateColors.dawnCoral,
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
                        style: TrueStateTypography.body.copyWith(
                          color: isSelected
                              ? TrueStateColors.textPrimaryDark
                              : TrueStateColors.textSecondaryDark,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TrueStateTypography.caption.copyWith(
                          color: TrueStateColors.textSecondaryDark,
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
              style: TrueStateTypography.caption.copyWith(
                color: TrueStateColors.textSecondaryDark,
                letterSpacing: 2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: TrueStateColors.dawnCoral.withAlpha(
                  (0.15 * 255).round(),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$value DAYS',
                style: TrueStateTypography.statNumber.copyWith(
                  fontSize: 16,
                  color: TrueStateColors.dawnCoral,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: TrueStateColors.dawnCoral,
            inactiveTrackColor: TrueStateColors.borderDark,
            thumbColor: TrueStateColors.dawnCoral,
            overlayColor: TrueStateColors.dawnCoral.withAlpha(
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
              style: TrueStateTypography.caption.copyWith(
                color: TrueStateColors.borderDark,
                fontSize: 10,
              ),
            ),
            Text(
              '365 days',
              style: TrueStateTypography.caption.copyWith(
                color: TrueStateColors.borderDark,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Simple configuration sheet for the Stoic widget.
class _StoicConfigSheet extends StatefulWidget {
  final Future<void> Function() onSave;

  const _StoicConfigSheet({required this.onSave});

  @override
  State<_StoicConfigSheet> createState() => _StoicConfigSheetState();
}

class _StoicConfigSheetState extends State<_StoicConfigSheet> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
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
                  color: TrueStateColors.borderDark,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'STOIC WIDGET',
              style: TrueStateTypography.h2.copyWith(
                color: TrueStateColors.dawnCoral,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TrueStateColors.darkBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TrueStateColors.borderDark),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.format_quote,
                    color: TrueStateColors.dawnCoral,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Daily Wisdom',
                    style: TrueStateTypography.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This widget displays a new stoic quote each day to inspire '
                    'and motivate your recovery journey. The quotes appear as '
                    'simple wisdom - no one will know what you\'re tracking.',
                    style: TrueStateTypography.body.copyWith(
                      color: TrueStateColors.textSecondaryDark,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Enable button
            ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: TrueStateColors.dawnCoral,
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
                        color: TrueStateColors.darkBackground,
                      ),
                    )
                  : Text(
                      'ENABLE WIDGET',
                      style: TrueStateTypography.button.copyWith(
                        color: TrueStateColors.darkBackground,
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
                style: TrueStateTypography.button.copyWith(
                  color: TrueStateColors.textSecondaryDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    HapticService.medium();

    await widget.onSave();

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

/// Bio-state widget configuration sheet.
class _BioStateConfigSheet extends StatefulWidget {
  final String? currentMetricId;
  final Future<void> Function(String metricId) onSave;

  const _BioStateConfigSheet({this.currentMetricId, required this.onSave});

  @override
  State<_BioStateConfigSheet> createState() => _BioStateConfigSheetState();
}

class _BioStateConfigSheetState extends State<_BioStateConfigSheet> {
  late String? _selectedMetricId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMetricId = widget.currentMetricId ?? 'gaba';
  }

  @override
  Widget build(BuildContext context) {
    final allMetrics = BioStates.getAllMetrics();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                  color: TrueStateColors.borderDark,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'BIO-STATE WIDGET',
              style: TrueStateTypography.h2.copyWith(
                color: TrueStateColors.dawnCoral,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select the recovery metric to display',
              style: TrueStateTypography.caption.copyWith(
                color: TrueStateColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Metric list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: allMetrics.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final metric = allMetrics[index];
                  final isSelected = _selectedMetricId == metric.id;

                  return _MetricOption(
                    metric: metric,
                    isSelected: isSelected,
                    onTap: () {
                      HapticService.light();
                      setState(() => _selectedMetricId = metric.id);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: (_isSaving || _selectedMetricId == null)
                  ? null
                  : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: TrueStateColors.dawnCoral,
                disabledBackgroundColor: TrueStateColors.dawnCoral.withAlpha(
                  (0.3 * 255).round(),
                ),
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
                        color: TrueStateColors.darkBackground,
                      ),
                    )
                  : Text(
                      'SAVE CONFIGURATION',
                      style: TrueStateTypography.button.copyWith(
                        color: TrueStateColors.darkBackground,
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
                style: TrueStateTypography.button.copyWith(
                  color: TrueStateColors.textSecondaryDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_selectedMetricId == null) return;

    setState(() => _isSaving = true);
    HapticService.medium();

    await widget.onSave(_selectedMetricId!);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

/// Radio option for metric selection.
class _MetricOption extends StatelessWidget {
  final BioStateMetric metric;
  final bool isSelected;
  final VoidCallback onTap;

  const _MetricOption({
    required this.metric,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? TrueStateColors.dawnCoral.withAlpha((0.1 * 255).round())
            : TrueStateColors.darkBackground,
        border: Border.all(
          color: isSelected
              ? TrueStateColors.dawnCoral
              : TrueStateColors.borderDark,
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
                          ? TrueStateColors.dawnCoral
                          : TrueStateColors.borderDark,
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
                              color: TrueStateColors.dawnCoral,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Metric info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            metric.stealthLabel.toUpperCase(),
                            style: TrueStateTypography.caption.copyWith(
                              color: isSelected
                                  ? TrueStateColors.dawnCoral
                                  : TrueStateColors.textSecondaryDark,
                              letterSpacing: 2,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            metric.displayName,
                            style: TrueStateTypography.caption.copyWith(
                              color: TrueStateColors.borderDark,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metric.description,
                        style: TrueStateTypography.caption.copyWith(
                          color: TrueStateColors.textSecondaryDark,
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
