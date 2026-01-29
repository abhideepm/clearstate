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
import 'core/services/hive_adapter_registry.dart';
import 'core/services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050505),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();

  // Register all Hive adapters in one place
  HiveAdapterRegistry.registerAll();

  await Hive.openBox<WidgetConfig>(HiveBoxes.widgetConfigs);
  await Hive.openBox('theme_settings');

  await NotificationService.instance.init();

  final repository = SobrietyRepository();
  await repository.init();

  // Initialize RevenueCat SDK
  final subscriptionService = SubscriptionService();
  await subscriptionService.initialize();

  final widgetService = WidgetUpdateService();
  await widgetService.initializeWidgets();

  runApp(
    ProviderScope(
      overrides: [
        sobrietyRepositoryProvider.overrideWithValue(repository),
        widgetUpdateServiceProvider.overrideWithValue(widgetService),
      ],
      child: const ClearStateApp(),
    ),
  );
}
