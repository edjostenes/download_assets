import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';

abstract class FileManager {
  Future<bool> directoryExists(String directory);

  Future<bool> fileExists(String fileDir);

  Future<FileSystemEntity> deleteFile(File file, {bool recursive = false});

  Future<FileSystemEntity> deleteDirectory(String directoryPath, {bool recursive = false});

  Future<Directory> createDirectory(String directoryPath, {bool recursive = false});

  File createFile(String fullPath);

  Archive decodeBytes(List<int> data, {bool verify = false, String? password});

  Future<String> getApplicationPath();

  Uint8List readAsBytesSync(File file);

  Future<File> createFileRecursively(File file);

  Future<File> writeAsBytes(File file, List<int> bytes);
}
