import 'package:hive/hive.dart';

part 'relapse_event.g.dart';

@HiveType(typeId: 2)
class RelapseEvent extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String habitId;

  @HiveField(6)
  int streakDaysLost;

  /// Whether this was a momentary slip (true) or a full relapse (false).
  /// Slips do NOT reset the sobriety timer - they only mark the day on heatmap.
  @HiveField(8)
  bool isSlip;

  RelapseEvent({
    required this.id,
    required this.timestamp,
    required this.habitId,
    required this.streakDaysLost,
    this.isSlip = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'habitId': habitId,
      'streakDaysLost': streakDaysLost,
      'isSlip': isSlip,
    };
  }

  factory RelapseEvent.fromJson(Map<String, dynamic> json) {
    return RelapseEvent(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      habitId: json['habitId'] as String? ?? 'default',
      streakDaysLost: json['streakDaysLost'] as int,
      isSlip: json['isSlip'] as bool? ?? false,
    );
  }
}
