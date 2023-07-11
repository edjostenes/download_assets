import 'dart:io';

import 'package:archive/archive.dart';

/// Abstract class representing a delegate for asset decompression.
abstract class UncompressDelegate {
  const UncompressDelegate();

  /// Gets the file extension associated with the delegate.
  String get extension;

  /// uncompress the asset located at [compressedFilePath] to the specified [assetsDir].
  /// [compressedFilePath] -> The path to the compressed asset file.
  /// [assetsDir] -> The directory where the uncompressed asset should be stored.
  /// Returns a [Future] representing the completion of the decompression process.
  Future uncompress(String compressedFilePath, String assetsDir);
}

/// A delegate for uncompressing ZIP files.
///
/// This class implements the [UncompressDelegate] interface.
///
/// Usage:
/// ```dart
/// UncompressDelegate unzipDelegate = UnzipDelegate();
/// ```
class UnzipDelegate implements UncompressDelegate {
  const UnzipDelegate();

  @override
  String get extension => '.zip';

  @override
  Future uncompress(String compressedFilePath, String assetsDir) async {
    final compressedFile = File(compressedFilePath);
    final bytes = await compressedFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    await compressedFile.delete();
    await Future.wait(archive.files.map((file) async {
      if (!file.isFile) {
        return;
      }

      final fileName = '$assetsDir/${file.name}';
      final outFile = await File(fileName).create(recursive: true);
      await outFile.writeAsBytes(file.content);
    }));
  }
}
