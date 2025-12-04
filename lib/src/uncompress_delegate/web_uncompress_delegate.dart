import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../download_assets.dart';
import '../managers/file/web_file_manager_impl.dart';

class WebUncompressDelegate implements UncompressDelegate {
  const WebUncompressDelegate();

  @override
  String get extension => '.zip';

  @override
  Future<void> uncompress(String compressedFilePath, String assetsDir) async {
    try {
      final fileManager = WebFileManagerImpl();
      final zipData = await fileManager.readFile(compressedFilePath);
      final archive = ZipDecoder().decodeBytes(zipData);

      for (final file in archive) {
        if (file.isFile) {
          final filePath = '$assetsDir/${file.name}';
          final fileData = Uint8List.fromList(file.content);
          await fileManager.writeFile(filePath, fileData);
        }
      }
    } catch (e) {
      throw DownloadAssetsException('Error to extract files: $e');
    }
  }
}
