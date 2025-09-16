import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> uploadProfilePhotoImpl(String userId, String filePath) async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/profile_photos');

    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final targetPath = '${photoDir.path}/$fileName';

    final sourceFile = File(filePath);
    final targetFile = await sourceFile.copy(targetPath);
    return targetFile.path;
  } catch (e) {
    throw Exception('Profil fotoğrafı yüklenirken hata oluştu: $e');
  }
}

Future<void> deleteStoredPhotoImpl(String userId, String storedPath) async {
  try {
    final file = File(storedPath);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {}
}
