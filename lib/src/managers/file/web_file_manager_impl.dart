import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../download_assets.dart';
import 'file_manager.dart';

class WebFileManagerImpl implements FileManager {
  late SharedPreferences _prefs;

  Future<SharedPreferences> get _preferences async => _prefs = await SharedPreferences.getInstance();

  @override
  Future<void> createDirectory(String directoryPath, {bool recursive = false}) => Future.value();

  @override
  Future<void> deleteDirectory(String directoryPath, {bool recursive = false}) async {
    await _preferences;
    final keysToRemove = _prefs.getKeys().where((key) => key.startsWith(directoryPath)).toList();

    for (final key in keysToRemove) {
      await _prefs.remove(key);
    }
  }

  @override
  Future<bool> directoryExists(String directory) async {
    await _preferences;
    return _prefs.getKeys().any((key) => key.startsWith(directory));
  }

  @override
  Future<bool> fileExists(String fileDir) async {
    await _preferences;
    return _prefs.containsKey(fileDir);
  }

  @override
  Future<String> getApplicationPath() async => '';

  @override
  Future<Uint8List> readFile(String path) async {
    await _preferences;
    final fileKey = path;
    final base64String = _prefs.getString(fileKey);

    if (base64String == null) {
      throw DownloadAssetsException('Fail to read file: $path');
    }

    final data = base64.decode(base64String);
    return Uint8List.fromList(data);
  }

  @override
  Future<void> writeFile(String path, Uint8List data) async {
    await _preferences;
    final fileKey = path;
    final base64String = base64.encode(data as List<int>);
    final success = await _prefs.setString(fileKey, base64String);

    if (!success) {
      throw DownloadAssetsException('Fail to save file: $path');
    }
  }
}
