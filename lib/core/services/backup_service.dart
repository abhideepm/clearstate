import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/repositories/sobriety_repository.dart';

class BackupService {
  final SobrietyRepository _repository;

  BackupService(this._repository);

  Future<void> createBackup() async {
    try {
      final data = _repository.exportData();
      final jsonString = jsonEncode(data);

      final tempDir = await getTemporaryDirectory();
      final dateStr = DateTime.now().toIso8601String().split('T')[0];
      final file = File('${tempDir.path}/clearstate_backup_$dateStr.json');

      await file.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'ClearState Backup - $dateStr',
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> restoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // Basic validation
      if (!data.containsKey('profile') && !data.containsKey('sessions')) {
        throw Exception('Invalid backup file');
      }

      await _repository.importData(data);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final repository = ref.watch(sobrietyRepositoryProvider);
  return BackupService(repository);
});
