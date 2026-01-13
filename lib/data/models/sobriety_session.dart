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

  SobrietySession({
    required this.id,
    required this.startDate,
    this.endDate,
  });

  bool get isActive => endDate == null;

  Duration get elapsed {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate);
  }

  int get totalDays => elapsed.inDays;
}
