import 'dart:typed_data';

abstract interface class FileManager {
  Future<bool> directoryExists(String directory);

  Future<bool> fileExists(String fileDir);

  Future<void> deleteDirectory(String directoryPath, {bool recursive = false});

  Future<void> createDirectory(String directoryPath, {bool recursive = false});

  Future<String> getApplicationPath();

  Future<void> writeFile(String path, Uint8List data);

  Future<Uint8List> readFile(String path);
}
