import 'package:hive/hive.dart';

part 'widget_config.g.dart';

/// Available widget types for the home screen.
enum WidgetType {
  /// Circular progress ring showing sobriety progress.
  battery,

  /// Daily stoic quote widget.
  stoic,

  /// Health metric graph showing recovery biomarkers.
  bioState,
}

/// Display modes for the battery widget.
enum BatteryDisplayMode {
  /// Progress toward the next recovery milestone.
  milestone,

  /// Streak as percentage of user-defined goal.
  goal,

  /// Percentage of current day completed sober.
  daily,
}

/// Configuration for a home screen widget.
@HiveType(typeId: 4)
class WidgetConfig extends HiveObject {
  /// The type of widget ('battery', 'stoic', 'bioState').
  @HiveField(0)
  String widgetType;

  /// Display mode for battery widget ('milestone', 'goal', 'daily').
  @HiveField(1)
  String batteryMode;

  /// Metric ID for bioState widget ('gaba', 'dopamine', 'sleep', etc.).
  @HiveField(2)
  String? bioStateMetricId;

  /// Number of days for goal mode (default 30).
  @HiveField(3)
  int goalDays;

  /// Whether this widget is currently active.
  @HiveField(4)
  bool isEnabled;

  WidgetConfig({
    required this.widgetType,
    this.batteryMode = 'milestone',
    this.bioStateMetricId,
    this.goalDays = 30,
    this.isEnabled = true,
  });

  /// Get the typed widget type enum.
  WidgetType get type {
    switch (widgetType) {
      case 'battery':
        return WidgetType.battery;
      case 'stoic':
        return WidgetType.stoic;
      case 'bioState':
        return WidgetType.bioState;
      default:
        return WidgetType.battery;
    }
  }

  /// Get the typed battery display mode enum.
  BatteryDisplayMode get displayMode {
    switch (batteryMode) {
      case 'milestone':
        return BatteryDisplayMode.milestone;
      case 'goal':
        return BatteryDisplayMode.goal;
      case 'daily':
        return BatteryDisplayMode.daily;
      default:
        return BatteryDisplayMode.milestone;
    }
  }

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'widgetType': widgetType,
      'batteryMode': batteryMode,
      'bioStateMetricId': bioStateMetricId,
      'goalDays': goalDays,
      'isEnabled': isEnabled,
    };
  }

  factory WidgetConfig.fromJson(Map<String, dynamic> json) {
    return WidgetConfig(
      widgetType: json['widgetType'] as String,
      batteryMode: json['batteryMode'] as String? ?? 'milestone',
      bioStateMetricId: json['bioStateMetricId'] as String?,
      goalDays: json['goalDays'] as int? ?? 30,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}
