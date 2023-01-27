import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

import 'file_manager.dart';

class FileManagerImpl implements FileManager {
  @override
  Future<Directory> createDirectory(String directoryPath,
          {bool recursive = false}) async =>
      await Directory(directoryPath).create(recursive: recursive);

  @override
  File createFile(String fullPath) => File(fullPath);

  @override
  Archive decodeBytes(List<int> data,
          {bool verify = false, String? password}) =>
      ZipDecoder().decodeBytes(data, verify: verify, password: password);

  @override
  Future<FileSystemEntity> deleteFile(File file,
          {bool recursive = false}) async =>
      await file.delete();

  @override
  Future<FileSystemEntity> deleteDirectory(String directoryPath,
          {bool recursive = false}) async =>
      await Directory(directoryPath).delete(recursive: true);

  @override
  Future<bool> directoryExists(String directoryPath) async =>
      await Directory(directoryPath).exists();

  @override
  Future<bool> fileExists(String fileDir) async => await File(fileDir).exists();

  @override
  Future<String> getApplicationPath() async =>
      (await getApplicationDocumentsDirectory()).path;

  @override
  Uint8List readAsBytesSync(File file) => file.readAsBytesSync();

  @override
  Future<File> createFileRecursively(File file) async =>
      await file.create(recursive: true);

  @override
  Future<File> writeAsBytes(File file, List<int> bytes) async =>
      await file.writeAsBytes(bytes);
}
