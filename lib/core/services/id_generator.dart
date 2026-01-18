import 'package:uuid/uuid.dart';

/// Generates unique identifiers for entities using UUID v4.
class IdGenerator {
  static const Uuid _uuid = Uuid();

  /// Generates a UUID v4 (random-based) string.
  static String uuid() => _uuid.v4();

  /// Validates that a string is a valid UUID v4 format.
  static bool isValidUuid(String id) {
    return Uuid.isValidUUID(fromString: id);
  }
}
