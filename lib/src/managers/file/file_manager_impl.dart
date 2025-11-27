import 'dart:io';
import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:path_provider/path_provider.dart';

import 'file_manager.dart';

class FileManagerImpl implements FileManager {
  @override
  Future<void> createDirectory(String directoryPath, {bool recursive = false}) =>
      Directory(directoryPath).create(recursive: recursive);

  @override
  Future<void> deleteDirectory(String directoryPath, {bool recursive = false}) =>
      Directory(directoryPath).delete(recursive: true);

  @override
  Future<bool> directoryExists(String directoryPath) => Directory(directoryPath).exists();

  @override
  Future<bool> fileExists(String fileDir) => File(fileDir).exists();

  @override
  Future<String> getApplicationPath() async => (await getApplicationDocumentsDirectory()).path;

  @override
  Future<Uint8List> readFile(String path) {
    // TODO: implement readFile
    throw UnimplementedError();
  }

  @override
  Future<void> writeFile(String path, Uint8List data) {
    // TODO: implement writeFile
    throw UnimplementedError();
  }
}
