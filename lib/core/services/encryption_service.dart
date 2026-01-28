import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pointycastle/export.dart';

/// Manages encryption keys for Hive box encryption.
/// Keys are stored in OS secure storage (Keychain/Keystore).
class EncryptionService {
  static const String _hiveKeyName = 'hive_encryption_key';
  static const int _saltLength = 16;
  static const int _ivLength = 12; // Standard for AES-GCM
  static const int _tagLength = 16;
  static const int _iterations = 10000;
  static const int _keyLength = 32; // 256 bits

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Encrypts a JSON payload using a password.
  /// Returns a base64 encoded string containing salt + iv + ciphertext.
  static String encryptPayload(String json, String password) {
    final salt = _generateRandomBytes(_saltLength);
    final key = _deriveKey(password, salt);
    final iv = _generateRandomBytes(_ivLength);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), _tagLength * 8, iv, Uint8List(0)));

    final input = utf8.encode(json);
    final ciphertext = cipher.process(input);

    final result = BytesBuilder()
      ..add(salt)
      ..add(iv)
      ..add(ciphertext);

    return base64UrlEncode(result.toBytes());
  }

  /// Decrypts a base64 encoded payload using a password.
  static String decryptPayload(String encrypted, String password) {
    try {
      final data = base64Url.decode(encrypted);
      if (data.length < _saltLength + _ivLength + _tagLength) {
        throw Exception('Invalid encrypted payload: too short');
      }

      final salt = data.sublist(0, _saltLength);
      final iv = data.sublist(_saltLength, _saltLength + _ivLength);
      final ciphertext = data.sublist(_saltLength + _ivLength);

      final key = _deriveKey(password, salt);

      final cipher = GCMBlockCipher(AESEngine())
        ..init(false, AEADParameters(KeyParameter(key), _tagLength * 8, iv, Uint8List(0)));

      final decrypted = cipher.process(ciphertext);
      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('Decryption failed: check password or data integrity');
    }
  }

  static Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  }

  static Uint8List _deriveKey(String password, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, _iterations, _keyLength));
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

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
