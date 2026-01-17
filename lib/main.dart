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

  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(WidgetConfigAdapter());
  }

  await Hive.openBox<WidgetConfig>(HiveBoxes.widgetConfigs);

  await Hive.openBox('theme_settings');

  await NotificationService.instance.init();

  final repository = SobrietyRepository();
  await repository.init();

  final widgetService = WidgetUpdateService();
  await widgetService.initializeWidgets();

  await _updateWidgetsOnStartup(repository);

  runApp(
    ProviderScope(
      overrides: [sobrietyRepositoryProvider.overrideWithValue(repository)],
      child: const ClearStateApp(),
    ),
  );
}

Future<void> _updateWidgetsOnStartup(SobrietyRepository repository) async {
  await repository.triggerWidgetUpdate();
}
