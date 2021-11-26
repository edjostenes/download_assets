import 'dart:io';

import 'package:archive/archive.dart';
import 'package:download_assets/src/managers/file/file_manager.dart';
import 'package:path_provider/path_provider.dart';

class FileManagerImpl implements FileManager {
  @override
  Future<Directory> createDirectory(String directoryPath, {bool recursive = false}) async {
    return await Directory(directoryPath).create(recursive: recursive);
  }

  @override
  File createFile(String fullPath) {
    return File(fullPath);
  }

  @override
  Archive decodeBytes(List<int> data, {bool verify = false, String? password}) {
    return ZipDecoder().decodeBytes(data, verify: verify, password: password);
  }

  @override
  Future<FileSystemEntity> deleteFile(File file, {bool recursive = false}) async {
    return await file.delete();
  }

  @override
  Future<FileSystemEntity> deleteDirectory(String directoryPath, {bool recursive = false}) async {
    return await Directory(directoryPath).delete(recursive: true);
  }

  @override
  Future<bool> directoryExists(String directoryPath) async {
    return await Directory(directoryPath).exists();
  }

  @override
  Future<bool> fileExists(String fileDir) async {
    return await File(fileDir).exists();
  }

  @override
  Future<String> getApplicationPath() async {
    return (await getApplicationDocumentsDirectory()).path;
  }
}
