import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';

/// Abstract interface for encryption operations.
/// Enables proper mocking in tests and dependency inversion.
abstract class IEncryptionService {
  /// Encrypts a JSON payload using a password.
  /// Returns a base64 encoded string containing salt + iv + ciphertext.
  String encryptPayload(String json, String password);

  /// Decrypts a base64 encoded payload using a password.
  String decryptPayload(String encrypted, String password);

  /// Get or create the Hive encryption cipher.
  Future<HiveAesCipher> getEncryptionCipher();

  /// Delete the encryption key (for factory reset).
  Future<void> deleteEncryptionKey();

  /// Check if an encryption key exists.
  Future<bool> hasEncryptionKey();

  /// Get raw encryption key bytes.
  Future<Uint8List> getEncryptionKeyBytes();
}
