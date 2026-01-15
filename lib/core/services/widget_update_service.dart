import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/models/widget_config.dart';

/// Service for syncing data to native home screen widgets using the home_widget package.
///
/// This service provides a unified interface for:
/// - Initializing widget communication (App Group ID, callbacks)
/// - Saving widget data to native storage
/// - Triggering native widget refreshes
/// - Handling deep links from widget taps
class WidgetUpdateService {
  /// iOS widget extension name (matches WidgetBundle name).
  static const String _iOSWidgetName = 'ClearStateWidgets';

  /// Android widget provider class names.
  static const String _androidBatteryWidget = 'BatteryWidgetProvider';
  static const String _androidStoicWidget = 'StoicWidgetProvider';
  static const String _androidBioStateWidget = 'BioStateWidgetProvider';

  /// iOS App Group ID for shared data container.
  static const String _appGroupId = 'group.com.clearstate.clearstate';

  /// Stream subscription for widget click events.
  StreamSubscription<Uri?>? _widgetClickSubscription;

  /// Callback for handling widget click deep links.
  void Function(Uri?)? _onWidgetClick;

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  /// Initialize the widget service.
  ///
  /// Call this once on app startup to:
  /// - Set the iOS App Group ID for shared data container
  /// - Register callback for widget click deep links
  /// - Listen for widget click stream events
  Future<void> initializeWidgets({void Function(Uri?)? onWidgetClick}) async {
    if (_isInitialized) return;

    _onWidgetClick = onWidgetClick;

    try {
      // Set App Group ID for iOS widget communication
      await HomeWidget.setAppGroupId(_appGroupId);

      // Register interactivity callback for widget clicks
      await HomeWidget.registerInteractivityCallback(_backgroundCallback);

      // Listen for widget click stream (when app is already running)
      _widgetClickSubscription = HomeWidget.widgetClicked.listen((uri) {
        _handleWidgetClickInternal(uri);
      });

      // Check if app was launched from widget
      final launchUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (launchUri != null) {
        _handleWidgetClickInternal(launchUri);
      }

      _isInitialized = true;
      debugPrint('WidgetUpdateService: Initialized successfully');
    } catch (e) {
      debugPrint('WidgetUpdateService: Error initializing widgets: $e');
    }
  }

  /// Background callback for widget interactivity.
  ///
  /// This is a top-level function required by home_widget for background execution.
  @pragma('vm:entry-point')
  static Future<void> _backgroundCallback(Uri? uri) async {
    debugPrint('WidgetUpdateService: Background callback received: $uri');
    // Background callbacks are handled by the native side
    // The app will be launched with the URI for full handling
  }

  /// Handle widget click deep links.
  ///
  /// [uri] contains the deep link data from the widget tap.
  /// Possible schemes:
  /// - `clearstate://timer` - Navigate to timer tab
  /// - `clearstate://timeline` - Navigate to timeline tab
  /// - `clearstate://analytics` - Navigate to analytics tab
  void handleWidgetClick(Uri? uri) {
    _handleWidgetClickInternal(uri);
  }

  /// Internal handler for widget clicks.
  void _handleWidgetClickInternal(Uri? uri) {
    if (uri == null) return;

    debugPrint('WidgetUpdateService: Widget clicked with URI: $uri');

    // Invoke registered callback if present
    _onWidgetClick?.call(uri);
  }

  /// Update all widgets with current data.
  ///
  /// This method saves data to native storage for each widget type
  /// and triggers a refresh. Call this whenever sobriety data changes.
  ///
  /// [dataService] provides computed widget data (progress, quotes, metrics).
  /// [batteryConfig] configuration for the battery widget (optional).
  /// [stoicConfig] configuration for the stoic widget (optional).
  /// [bioStateConfig] configuration for the bio-state widget (optional).
  Future<void> updateAllWidgets({
    required WidgetData data,
    WidgetConfig? batteryConfig,
    WidgetConfig? stoicConfig,
    WidgetConfig? bioStateConfig,
  }) async {
    try {
      // Update Battery Widget
      if (batteryConfig?.isEnabled ?? true) {
        await _updateBatteryWidget(
          progress: data.batteryProgress,
          mode: batteryConfig?.batteryMode ?? 'milestone',
          streakDays: data.streakDays,
          goalDays: batteryConfig?.goalDays ?? 30,
        );
      }

      // Update Stoic Widget
      if (stoicConfig?.isEnabled ?? true) {
        await _updateStoicWidget(
          quoteText: data.stoicQuote,
          quoteAuthor: data.stoicAuthor,
        );
      }

      // Update Bio-State Widget
      if (bioStateConfig?.isEnabled ?? true) {
        await _updateBioStateWidget(
          metricId: bioStateConfig?.bioStateMetricId ?? 'gaba',
          label: data.bioStateLabel,
          value: data.bioStateValue,
        );
      }

      // Trigger native widget refresh
      await refreshWidgets();

      debugPrint('WidgetUpdateService: All widgets updated successfully');
    } catch (e) {
      debugPrint('WidgetUpdateService: Error updating widgets: $e');
    }
  }

  /// Update Battery widget data.
  Future<void> _updateBatteryWidget({
    required double progress,
    required String mode,
    required int streakDays,
    required int goalDays,
  }) async {
    try {
      await HomeWidget.saveWidgetData<double>('battery_progress', progress);
      await HomeWidget.saveWidgetData<String>('battery_mode', mode);
      await HomeWidget.saveWidgetData<int>('battery_streak', streakDays);
      await HomeWidget.saveWidgetData<int>('battery_goal', goalDays);

      debugPrint(
        'WidgetUpdateService: Battery widget updated - '
        'progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'mode: $mode, streak: $streakDays days',
      );
    } catch (e) {
      debugPrint('WidgetUpdateService: Error updating battery widget: $e');
    }
  }

  /// Update Stoic quote widget data.
  Future<void> _updateStoicWidget({
    required String quoteText,
    required String quoteAuthor,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('stoic_quote', quoteText);
      await HomeWidget.saveWidgetData<String>('stoic_author', quoteAuthor);

      debugPrint(
        'WidgetUpdateService: Stoic widget updated - '
        '"${quoteText.length > 50 ? '${quoteText.substring(0, 50)}...' : quoteText}"',
      );
    } catch (e) {
      debugPrint('WidgetUpdateService: Error updating stoic widget: $e');
    }
  }

  /// Update Bio-State metric widget data.
  Future<void> _updateBioStateWidget({
    required String metricId,
    required String label,
    required double value,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('biostate_metric_id', metricId);
      await HomeWidget.saveWidgetData<String>('biostate_label', label);
      await HomeWidget.saveWidgetData<double>('biostate_value', value);

      debugPrint(
        'WidgetUpdateService: Bio-State widget updated - '
        '$label: ${(value * 100).toStringAsFixed(1)}%',
      );
    } catch (e) {
      debugPrint('WidgetUpdateService: Error updating bio-state widget: $e');
    }
  }

  /// Clear all widget data.
  ///
  /// Call this after data wipe/factory reset to ensure widgets don't display
  /// stale recovery data (privacy protection).
  Future<void> clearAllWidgets() async {
    try {
      // Clear Battery Widget data
      await HomeWidget.saveWidgetData<double>('battery_progress', 0.0);
      await HomeWidget.saveWidgetData<String>('battery_mode', 'milestone');
      await HomeWidget.saveWidgetData<int>('battery_streak', 0);
      await HomeWidget.saveWidgetData<int>('battery_goal', 30);

      // Clear Stoic Widget data (show default inspirational quote)
      await HomeWidget.saveWidgetData<String>(
        'stoic_quote',
        'Begin at once to live.',
      );
      await HomeWidget.saveWidgetData<String>('stoic_author', 'Seneca');

      // Clear Bio-State Widget data
      await HomeWidget.saveWidgetData<String>('biostate_metric_id', 'recovery');
      await HomeWidget.saveWidgetData<String>('biostate_label', 'Wellness');
      await HomeWidget.saveWidgetData<double>('biostate_value', 0.0);

      // Trigger refresh to show cleared data
      await refreshWidgets();

      debugPrint('WidgetUpdateService: All widgets cleared');
    } catch (e) {
      debugPrint('WidgetUpdateService: Error clearing widgets: $e');
    }
  }

  /// Trigger native widget refresh on all platforms.
  ///
  /// This tells the OS to reload the widget UI with the latest saved data.
  /// On iOS, uses the widget extension name.
  /// On Android, updates each widget provider separately.
  Future<void> refreshWidgets() async {
    try {
      // Refresh Battery Widget
      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidBatteryWidget,
      );

      // Refresh Stoic Widget
      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidStoicWidget,
      );

      // Refresh Bio-State Widget
      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidBioStateWidget,
      );

      debugPrint('WidgetUpdateService: Widget refresh triggered');
    } catch (e) {
      debugPrint('WidgetUpdateService: Error refreshing widgets: $e');
    }
  }

  /// Update a single widget type.
  ///
  /// Use this when only one widget's data has changed.
  Future<void> refreshWidget(WidgetType type) async {
    try {
      String androidName;
      switch (type) {
        case WidgetType.battery:
          androidName = _androidBatteryWidget;
        case WidgetType.stoic:
          androidName = _androidStoicWidget;
        case WidgetType.bioState:
          androidName = _androidBioStateWidget;
      }

      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: androidName,
      );

      debugPrint(
        'WidgetUpdateService: Widget refresh triggered for ${type.name}',
      );
    } catch (e) {
      debugPrint(
        'WidgetUpdateService: Error refreshing ${type.name} widget: $e',
      );
    }
  }

  /// Request to pin (add) a widget to the user's home screen.
  ///
  /// Only supported on Android 8.0+ (API 26+).
  /// Returns true if the request was successful.
  Future<bool> requestPinWidget(WidgetType type) async {
    try {
      final isSupported = await HomeWidget.isRequestPinWidgetSupported();
      if (isSupported != true) {
        debugPrint(
          'WidgetUpdateService: Pin widget not supported on this device',
        );
        return false;
      }

      String androidName;
      switch (type) {
        case WidgetType.battery:
          androidName = _androidBatteryWidget;
        case WidgetType.stoic:
          androidName = _androidStoicWidget;
        case WidgetType.bioState:
          androidName = _androidBioStateWidget;
      }

      await HomeWidget.requestPinWidget(androidName: androidName);
      debugPrint('WidgetUpdateService: Pin widget requested for ${type.name}');
      return true;
    } catch (e) {
      debugPrint('WidgetUpdateService: Error requesting pin widget: $e');
      return false;
    }
  }

  /// Get list of currently installed widgets.
  ///
  /// Returns information about which widgets the user has added.
  Future<List<HomeWidgetInfo>> getInstalledWidgets() async {
    try {
      return await HomeWidget.getInstalledWidgets();
    } catch (e) {
      debugPrint('WidgetUpdateService: Error getting installed widgets: $e');
      return [];
    }
  }

  /// Clean up resources.
  void dispose() {
    _widgetClickSubscription?.cancel();
    _widgetClickSubscription = null;
    _onWidgetClick = null;
    _isInitialized = false;
  }
}

/// Data structure for widget updates.
///
/// This provides a clean interface between the data layer and widget updates.
class WidgetData {
  /// Progress value for the battery widget (0.0 to 1.0).
  final double batteryProgress;

  /// Number of days in current streak.
  final int streakDays;

  /// Current stoic quote text.
  final String stoicQuote;

  /// Author of the current stoic quote.
  final String stoicAuthor;

  /// Label for the bio-state metric (stealth mode label).
  final String bioStateLabel;

  /// Current bio-state metric value (0.0 to 1.0).
  final double bioStateValue;

  const WidgetData({
    required this.batteryProgress,
    required this.streakDays,
    required this.stoicQuote,
    required this.stoicAuthor,
    required this.bioStateLabel,
    required this.bioStateValue,
  });

  /// Create default widget data.
  factory WidgetData.empty() {
    return const WidgetData(
      batteryProgress: 0.0,
      streakDays: 0,
      stoicQuote: 'The obstacle is the way.',
      stoicAuthor: 'Marcus Aurelius',
      bioStateLabel: 'Recovery',
      bioStateValue: 0.0,
    );
  }
}

/// Riverpod provider for the widget update service.
///
/// Access the service via: `ref.read(widgetUpdateServiceProvider)`
final widgetUpdateServiceProvider = Provider<WidgetUpdateService>((ref) {
  final service = WidgetUpdateService();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
