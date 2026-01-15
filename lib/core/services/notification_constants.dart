import '../constants/milestones.dart';

/// Notification content derived from recovery milestones.
/// Uses dayThreshold as notification ID for easy cancellation.
class MilestoneNotification {
  final int dayThreshold;
  final int notificationId;
  final String title;
  final String body;

  const MilestoneNotification({
    required this.dayThreshold,
    required this.notificationId,
    required this.title,
    required this.body,
  });

  /// Create notification from a RecoveryMilestone
  factory MilestoneNotification.fromMilestone(RecoveryMilestone milestone) {
    return MilestoneNotification(
      dayThreshold: milestone.dayThreshold,
      notificationId: milestone.dayThreshold, // ID = day threshold
      title: milestone.title,
      body: milestone.notificationBody, // Use generic notification body
    );
  }
}

class NotificationConstants {
  /// Channel configuration
  static const String channelId = 'clearstate_milestones';
  static const String channelName = 'Milestone Alerts';
  static const String channelDescription =
      'Notifications for sobriety milestones';

  /// Milestone notifications derived from RecoveryMilestones.
  /// Excludes day 0 (Hour Zero) since that's the starting point.
  static List<MilestoneNotification> get milestoneNotifications {
    return RecoveryMilestones.milestones
        .where((m) => m.dayThreshold > 0) // Skip "Hour Zero"
        .map((m) => MilestoneNotification.fromMilestone(m))
        .toList();
  }

  /// Get all notification IDs for bulk cancellation
  static List<int> get allNotificationIds =>
      milestoneNotifications.map((m) => m.notificationId).toList();
}
