import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'notification_constants.dart';
import 'notification_service_interface.dart';

class NotificationService implements INotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _isInitialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        if (granted != true) return false;
        await androidPlugin.requestExactAlarmsPermission();
      }
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(alert: true, badge: true, sound: false);
        return granted ?? false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) return await androidPlugin.areNotificationsEnabled() ?? false;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> scheduleMilestoneNotifications(DateTime sessionStartDate) async {
    if (!_isInitialized) return;
    try {
      final now = DateTime.now();
      final daysSober = now.difference(sessionStartDate).inDays;
      for (final milestone in NotificationConstants.milestoneNotifications) {
        if (daysSober >= milestone.dayThreshold) continue;
        final scheduledTime = sessionStartDate.add(Duration(days: milestone.dayThreshold));
        if (scheduledTime.isBefore(now)) continue;
        await _scheduleNotification(
          id: milestone.notificationId,
          title: milestone.title,
          body: milestone.body,
          scheduledTime: scheduledTime,
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  /// Schedules a recurring daily check-in notification.
  Future<void> scheduleDailyCheckIn(int hour, int minute) async {
    if (!_isInitialized) return;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_checkin',
        'Daily Check-in',
        channelDescription: 'Reminder to log your mood and symptoms',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true),
    );

    await _plugin.zonedSchedule(
      9999, // Unique ID for daily check-in
      'Daily Check-in',
      'How are you feeling today? Tap to log your progress.',
      _nextInstanceOfTime(hour, minute),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationConstants.channelId,
        NotificationConstants.channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancelAllMilestoneNotifications() async {
    await _plugin.cancelAll();
  }

  @override
  Future<void> cancelNotificationById(int id) async {
    await _plugin.cancel(id);
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}
