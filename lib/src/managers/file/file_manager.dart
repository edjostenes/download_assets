import 'dart:io';

abstract class FileManager {
  Future<bool> directoryExists(String directory);

  Future<bool> fileExists(String fileDir);

  Future<FileSystemEntity> deleteDirectory(String directoryPath,
      {bool recursive = false});

  Future<Directory> createDirectory(String directoryPath,
      {bool recursive = false});

  Future<String> getApplicationPath();
}
