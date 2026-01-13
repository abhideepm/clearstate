import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

/// Abstract interface for notification service to enable testing.
abstract class INotificationService {
  Future<void> init();
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();
  Future<void> scheduleMilestoneNotifications(DateTime sessionStartDate);
  Future<void> cancelAllMilestoneNotifications();
  Future<void> cancelNotificationById(int id);
  Future<List<PendingNotificationRequest>> getPendingNotifications();
}

/// Provider for notification service.
/// Override this in tests with a mock implementation.
final notificationServiceProvider = Provider<INotificationService>((ref) {
  return NotificationService.instance;
});
