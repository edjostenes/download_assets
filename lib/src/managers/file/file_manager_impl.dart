import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'file_manager.dart';

class FileManagerImpl implements FileManager {
  @override
  Future<Directory> createDirectory(String directoryPath,
          {bool recursive = false}) =>
      Directory(directoryPath).create(recursive: recursive);

  @override
  Future<FileSystemEntity> deleteDirectory(String directoryPath,
          {bool recursive = false}) =>
      Directory(directoryPath).delete(recursive: true);

  @override
  Future<bool> directoryExists(String directoryPath) =>
      Directory(directoryPath).exists();

  @override
  Future<bool> fileExists(String fileDir) => File(fileDir).exists();

  @override
  Future<String> getApplicationPath() async =>
      (await getApplicationDocumentsDirectory()).path;
}
