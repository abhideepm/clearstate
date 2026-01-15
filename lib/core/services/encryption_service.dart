import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Manages encryption keys for Hive box encryption.
/// Keys are stored in OS secure storage (Keychain/Keystore).
class EncryptionService {
  static const String _hiveKeyName = 'hive_encryption_key';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Get or create the Hive encryption cipher.
  /// The key is stored in secure storage and persists across app reinstalls
  /// on iOS (Keychain) but not on Android (Keystore tied to app).
  static Future<HiveAesCipher> getEncryptionCipher() async {
    try {
      String? keyBase64 = await _secureStorage.read(key: _hiveKeyName);
      List<int> key;

      if (keyBase64 == null) {
        // Generate new 256-bit key
        key = Hive.generateSecureKey();
        keyBase64 = base64UrlEncode(key);
        await _secureStorage.write(key: _hiveKeyName, value: keyBase64);
        debugPrint('EncryptionService: Generated new encryption key');
      } else {
        key = base64Url.decode(keyBase64);
        debugPrint('EncryptionService: Loaded existing encryption key');
      }

      return HiveAesCipher(key);
    } catch (e) {
      debugPrint('EncryptionService: Error getting cipher: $e');
      // Fallback: generate a new key (data will be lost if key was corrupted)
      final key = Hive.generateSecureKey();
      try {
        await _secureStorage.write(
          key: _hiveKeyName,
          value: base64UrlEncode(key),
        );
      } catch (_) {
        // Secure storage not available, continue without persistence
      }
      return HiveAesCipher(key);
    }
  }

  /// Delete the encryption key (for factory reset).
  /// Warning: This will make all encrypted data unreadable.
  static Future<void> deleteEncryptionKey() async {
    try {
      await _secureStorage.delete(key: _hiveKeyName);
      debugPrint('EncryptionService: Deleted encryption key');
    } catch (e) {
      debugPrint('EncryptionService: Error deleting key: $e');
    }
  }

  /// Check if an encryption key exists.
  static Future<bool> hasEncryptionKey() async {
    try {
      final key = await _secureStorage.read(key: _hiveKeyName);
      return key != null;
    } catch (e) {
      return false;
    }
  }

  static Future<Uint8List> getEncryptionKeyBytes() async {
    final keyBase64 = await _secureStorage.read(key: _hiveKeyName);
    if (keyBase64 == null) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _hiveKeyName,
        value: base64UrlEncode(key),
      );
      return Uint8List.fromList(key);
    }
    return Uint8List.fromList(base64Url.decode(keyBase64));
  }
}
