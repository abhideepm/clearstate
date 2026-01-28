import 'package:hive/hive.dart';

part 'sobriety_session.g.dart';

@HiveType(typeId: 6)
class SobrietySession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime? endDate;

  SobrietySession({
    required this.id,
    required this.habitId,
    required this.startDate,
    this.endDate,
  });

  bool get isActive => endDate == null;

  SobrietySession copyWith({DateTime? endDate}) => SobrietySession(
    id: id,
    habitId: habitId,
    startDate: startDate,
    endDate: endDate ?? this.endDate,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'habitId': habitId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  };

  factory SobrietySession.fromJson(Map<String, dynamic> json) =>
      SobrietySession(
        id: json['id'] as String,
        habitId: json['habitId'] as String? ?? 'default',
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
      );
}
