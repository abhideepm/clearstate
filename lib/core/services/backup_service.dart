import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pointycastle/export.dart';
import '../../data/repositories/sobriety_repository.dart';
import '../../data/repositories/i_sobriety_repository.dart';
import 'encryption_service.dart';

class BackupService {
  static const _magic = 'CLRSTATE';
  static const _version = 1;
  static const _ivLength = 12;
  static const _tagBits = 128;

  final ISobrietyRepository _repository;

  BackupService(this._repository);

  Future<void> createBackup() async {
    final data = _repository.exportData();
    final jsonString = jsonEncode(data);

    final key = await EncryptionService.getEncryptionKeyBytes();
    final encryptedBytes = _encryptAesGcm(utf8.encode(jsonString), key);

    final tempDir = await getTemporaryDirectory();
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final file = File('${tempDir.path}/clearstate_backup_$dateStr.enc');

    await file.writeAsBytes(encryptedBytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'ClearState Backup - $dateStr (Encrypted)',
      ),
    );
  }

  Uint8List _encryptAesGcm(List<int> plainBytes, Uint8List key) {
    final iv = _secureRandomBytes(_ivLength);

    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      true,
      AEADParameters(KeyParameter(key), _tagBits, iv, Uint8List(0)),
    );

    final ciphertext = cipher.process(Uint8List.fromList(plainBytes));

    return Uint8List.fromList([
      ..._magic.codeUnits,
      _version,
      iv.length,
      ...iv,
      ...ciphertext,
    ]);
  }

  Uint8List _decryptAesGcm(Uint8List blob, Uint8List key) {
    final magicLen = _magic.length;

    if (blob.length < magicLen + 2 + _ivLength) {
      throw Exception('Invalid backup: file too short');
    }

    final magic = String.fromCharCodes(blob.sublist(0, magicLen));
    if (magic != _magic) {
      throw Exception('Invalid backup: unrecognized format');
    }

    final version = blob[magicLen];
    if (version != _version) {
      throw Exception('Unsupported backup version: $version');
    }

    final ivLen = blob[magicLen + 1];
    final ivStart = magicLen + 2;
    final iv = blob.sublist(ivStart, ivStart + ivLen);
    final ciphertext = blob.sublist(ivStart + ivLen);

    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      false,
      AEADParameters(KeyParameter(key), _tagBits, iv, Uint8List(0)),
    );

    try {
      return cipher.process(ciphertext);
    } catch (e) {
      throw Exception('Failed to decrypt backup. Wrong key or corrupted file.');
    }
  }

  Uint8List _secureRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  Future<bool> restoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['enc', 'json'],
    );

    if (result == null || result.files.single.path == null) {
      return false;
    }

    final file = File(result.files.single.path!);
    final fileBytes = await file.readAsBytes();
    final fileExtension = result.files.single.extension ?? '';

    Map<String, dynamic> data;

    if (fileExtension == 'enc') {
      final key = await EncryptionService.getEncryptionKeyBytes();
      final decrypted = _decryptAesGcm(Uint8List.fromList(fileBytes), key);
      final jsonString = utf8.decode(decrypted);
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } else {
      final jsonString = utf8.decode(fileBytes);
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    }

    if (!data.containsKey('profile') && !data.containsKey('sessions')) {
      throw Exception('Invalid backup file');
    }

    await _repository.importData(data);
    return true;
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final repository = ref.watch(sobrietyRepositoryProvider);
  return BackupService(repository);
});
