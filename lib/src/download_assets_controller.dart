import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:download_assets/src/download_assets_exception.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadAssetsController {
  
  static String _assetsDir;
  static String get assetsDir => _assetsDir;

  static Future init() async {
    String rootDir = (await getApplicationDocumentsDirectory()).path;
    _assetsDir = '$rootDir/assets';
  }

  /// If assets directory was already create it assumes that the content was already downloaded.
  static Future<bool> assetsDirAlreadyExists() async => await Directory(_assetsDir).exists();

  /// Clear all download assets, if it already exists on local storage.
  static Future clearAssets() async {
    bool assetsDirExists = await assetsDirAlreadyExists();

    if (!assetsDirExists)
      return;

    await Directory(_assetsDir).delete(recursive: true);
  }

  /// Start download of your content to local storage, uncompress all data and delete
  /// the compressed file.
  /// [assetsUrl] -> Specify the url for your compressed file. (http://{YOUR_DOMAIN}:{FILE_NAME}.zip
  /// [progressCallback] -> It's not required. If you provide this callback it will be called after each iteration
  /// returning the actual progress
  /// [errorCallback] -> It's not required. If you provider this callback it will be called when any exception to occur
  static Future startDownload({
    @required String assetsUrl,
    Function(double) progressCallback,
    Function(Exception) errorCallback,
  }) async {
    try {
      if (assetsUrl == null || assetsUrl.isEmpty)
        throw DownloadAssetsException("AssetUrl param can't be empty");

      await clearAssets();
      await Directory(_assetsDir).create();
      String fullPath = '$_assetsDir/assets.zip';
      double totalProgress = 0;

      await Dio().download(
        assetsUrl,
        fullPath,
        options: Options(
            headers: {HttpHeaders.acceptEncodingHeader: "*"},
            responseType: ResponseType.bytes
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total * 100);
            totalProgress = progress - (progress * 0.2);
          }

          if (progressCallback != null)
            progressCallback(totalProgress <= 0 ? 0 : totalProgress);
        },
      );

      var zipFile = File(fullPath);
      var bytes = zipFile.readAsBytesSync();
      var archive = ZipDecoder().decodeBytes(bytes);
      await zipFile.delete();
      double totalFiles = archive.length > 0 ? archive.length.toDouble() : 20;
      double increment = 20 / totalFiles;

      for (var file in archive) {
        var filename = '$_assetsDir/${file.name}';

        if (file.isFile) {
          var outFile = File(filename);
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
          totalProgress += increment;

          if (progressCallback != null)
            progressCallback(totalProgress);
        }
      }

      if (progressCallback != null)
        progressCallback(100);
    } catch (e) {
      DownloadAssetsException downloadAssetsException = DownloadAssetsException(e.toString(), exception: e);

      if (errorCallback != null)
        errorCallback(downloadAssetsException);
      else
        throw downloadAssetsException;
    }
  }
}