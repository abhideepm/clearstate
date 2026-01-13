import 'package:hive/hive.dart';

part 'sobriety_session.g.dart';

@HiveType(typeId: 1)
class SobrietySession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startDate;

  @HiveField(2)
  DateTime? endDate; // null = currently active

  SobrietySession({required this.id, required this.startDate, this.endDate});

  bool get isActive => endDate == null;

  Duration get elapsed {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate);
  }

  int get totalDays => elapsed.inDays;

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory SobrietySession.fromJson(Map<String, dynamic> json) {
    return SobrietySession(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }
}
