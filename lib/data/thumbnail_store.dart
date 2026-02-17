import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ThumbnailStore {
  static Future<Directory> _getThumbDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final thumbDir = Directory(p.join(dir.path, 'thumbs'));
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }
    return thumbDir;
  }

  static String _hashPath(String path) {
    final bytes = path.codeUnits;
    return md5.convert(bytes).toString();
  }

  static Future<String> saveThumbnail(String filePath, List<int> bytes) async {
    final dir = await _getThumbDir();
    final base = _hashPath(filePath);
    final outPath = p.join(dir.path, '$base.jpg');
    final outFile = File(outPath);
    await outFile.writeAsBytes(bytes, flush: true);
    return outPath;
  }

  static Future<void> clearThumbnails() async {
    try {
      final dir = await _getThumbDir();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (_) {
      // ignore
    }
  }
}
