import 'dart:io';

import 'package:archive/archive.dart';

abstract class UncompressDelegate {
  const UncompressDelegate();

  String get extension;

  Future uncompress(String compressedFilePath, String assetsDir);
}

class UnzipDelegate implements UncompressDelegate {
  const UnzipDelegate();

  @override
  String get extension => '.zip';

  @override
  Future uncompress(String compressedFilePath, String assetsDir) async {
    final compressedFile = File(compressedFilePath);
    final bytes = compressedFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    await compressedFile.delete();

    for (final file in archive) {
      final fileName = '$assetsDir/${file.name}';

      if (!file.isFile) {
        continue;
      }

      var outFile = File(fileName);
      outFile = await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content);
    }
  }
}
