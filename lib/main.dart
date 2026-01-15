import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/repositories/sobriety_repository.dart';
import 'data/models/widget_config.dart';
import 'core/constants/hive_boxes.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_update_service.dart';
import 'core/services/widget_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050505),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();

  // Register WidgetConfig adapter (typeId: 4)
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(WidgetConfigAdapter());
  }

  // Open widget configs box
  await Hive.openBox<WidgetConfig>(HiveBoxes.widgetConfigs);

  // Initialize notification service
  await NotificationService.instance.init();

  // Create and initialize repository
  final repository = SobrietyRepository();
  await repository.init();

  // Initialize widget update service
  final widgetService = WidgetUpdateService();
  await widgetService.initializeWidgets();

  // Update all widgets with initial data on startup
  await _updateWidgetsOnStartup(repository);

  runApp(
    ProviderScope(
      overrides: [sobrietyRepositoryProvider.overrideWithValue(repository)],
      child: const ClearStateApp(),
    ),
  );
}

/// Updates all home screen widgets with current sobriety data on app startup.
Future<void> _updateWidgetsOnStartup(
  SobrietyRepository repository,
) async {
  // Delegate to repository's centralized widget update method
  await repository.triggerWidgetUpdate();
}
