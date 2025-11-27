import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'file_manager.dart';

class WebFileManagerImpl implements FileManager {
  @override
  Future<void> createDirectory(String directoryPath, {bool recursive = false}) {
    // TODO: implement createDirectory
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDirectory(String directoryPath, {bool recursive = false}) {
    // TODO: implement deleteDirectory
    throw UnimplementedError();
  }

  @override
  Future<bool> directoryExists(String directory) {
    // TODO: implement directoryExists
    throw UnimplementedError();
  }

  @override
  Future<bool> fileExists(String fileDir) {
    // TODO: implement fileExists
    throw UnimplementedError();
  }

  @override
  Future<String> getApplicationPath() {
    // TODO: implement getApplicationPath
    throw UnimplementedError();
  }

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
