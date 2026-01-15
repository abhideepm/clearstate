import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../data/models/widget_config.dart';
import '../../../core/services/widget_update_service.dart';

/// State class containing all widget configurations.
class WidgetSettingsState {
  final WidgetConfig? batteryConfig;
  final WidgetConfig? stoicConfig;
  final WidgetConfig? bioStateConfig;
  final bool isLoading;

  const WidgetSettingsState({
    this.batteryConfig,
    this.stoicConfig,
    this.bioStateConfig,
    this.isLoading = false,
  });

  WidgetSettingsState copyWith({
    WidgetConfig? batteryConfig,
    WidgetConfig? stoicConfig,
    WidgetConfig? bioStateConfig,
    bool? isLoading,
  }) {
    return WidgetSettingsState(
      batteryConfig: batteryConfig ?? this.batteryConfig,
      stoicConfig: stoicConfig ?? this.stoicConfig,
      bioStateConfig: bioStateConfig ?? this.bioStateConfig,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Check if a widget type is configured.
  bool isConfigured(WidgetType type) {
    switch (type) {
      case WidgetType.battery:
        return batteryConfig != null;
      case WidgetType.stoic:
        return stoicConfig != null;
      case WidgetType.bioState:
        return bioStateConfig != null &&
            bioStateConfig!.bioStateMetricId != null;
    }
  }
}

/// StateNotifier for managing widget configurations.
///
/// Handles loading and saving widget configs to Hive storage,
/// and triggers widget updates when configurations change.
class WidgetSettingsNotifier extends StateNotifier<WidgetSettingsState> {
  final Ref _ref;
  static const String _boxName = 'widget_configs';

  WidgetSettingsNotifier(this._ref) : super(const WidgetSettingsState()) {
    loadConfigs();
  }

  /// Load all widget configurations from Hive storage.
  Future<void> loadConfigs() async {
    state = state.copyWith(isLoading: true);

    try {
      final box = await Hive.openBox<WidgetConfig>(_boxName);

      final batteryConfig = box.get('battery');
      final stoicConfig = box.get('stoic');
      final bioStateConfig = box.get('bioState');

      state = WidgetSettingsState(
        batteryConfig: batteryConfig ?? _createDefaultBatteryConfig(),
        stoicConfig: stoicConfig ?? _createDefaultStoicConfig(),
        bioStateConfig: bioStateConfig,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Create default battery widget configuration.
  WidgetConfig _createDefaultBatteryConfig() {
    return WidgetConfig(
      widgetType: 'battery',
      batteryMode: 'milestone',
      goalDays: 30,
      isEnabled: true,
    );
  }

  /// Create default stoic widget configuration.
  WidgetConfig _createDefaultStoicConfig() {
    return WidgetConfig(widgetType: 'stoic', isEnabled: true);
  }

  /// Save battery widget configuration.
  ///
  /// [mode] - The display mode ('milestone', 'goal', 'daily').
  /// [goalDays] - Number of days for goal mode (7-365).
  Future<void> saveBatteryConfig({
    required BatteryDisplayMode mode,
    required int goalDays,
  }) async {
    final config = WidgetConfig(
      widgetType: 'battery',
      batteryMode: mode.name,
      goalDays: goalDays,
      isEnabled: true,
    );

    await _saveConfig('battery', config);
    state = state.copyWith(batteryConfig: config);
    await _triggerWidgetUpdate(WidgetType.battery);
  }

  /// Save stoic widget configuration.
  ///
  /// The stoic widget doesn't have many configuration options,
  /// but this method exists for consistency and future expansion.
  Future<void> saveStoicConfig() async {
    final config = WidgetConfig(widgetType: 'stoic', isEnabled: true);

    await _saveConfig('stoic', config);
    state = state.copyWith(stoicConfig: config);
    await _triggerWidgetUpdate(WidgetType.stoic);
  }

  /// Save bio-state widget configuration.
  ///
  /// [metricId] - The ID of the bio metric to display ('gaba', 'dopamine', etc.).
  Future<void> saveBioStateConfig({required String metricId}) async {
    final config = WidgetConfig(
      widgetType: 'bioState',
      bioStateMetricId: metricId,
      isEnabled: true,
    );

    await _saveConfig('bioState', config);
    state = state.copyWith(bioStateConfig: config);
    await _triggerWidgetUpdate(WidgetType.bioState);
  }

  /// Save a widget configuration to Hive storage.
  Future<void> _saveConfig(String key, WidgetConfig config) async {
    try {
      final box = await Hive.openBox<WidgetConfig>(_boxName);
      await box.put(key, config);
    } catch (e) {
      // Handle error silently - widget will use defaults
    }
  }

  /// Trigger a widget update after configuration change.
  Future<void> _triggerWidgetUpdate(WidgetType type) async {
    try {
      final widgetService = _ref.read(widgetUpdateServiceProvider);
      await widgetService.refreshWidget(type);
    } catch (e) {
      // Handle error silently - widget refresh is non-critical
    }
  }
}

/// Provider for widget settings state and actions.
final widgetSettingsProvider =
    StateNotifierProvider<WidgetSettingsNotifier, WidgetSettingsState>((ref) {
      return WidgetSettingsNotifier(ref);
    });
