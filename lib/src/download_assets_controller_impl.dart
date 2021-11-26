import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:download_assets/src/download_assets_controller.dart';
import 'package:download_assets/src/exceptions/download_assets_exception.dart';
import 'package:path_provider/path_provider.dart';

DownloadAssetsController createObject({required String directory}) => DownloadAssetsControllerImpl(directory: directory);

class DownloadAssetsControllerImpl implements DownloadAssetsController {
  String? _assetsDir;

  @override
  String? get assetsDir => _assetsDir;

  DownloadAssetsControllerImpl({required String directory}) {
    _init(directory);
  }

  void _init(String directory) async {
    String rootDir = (await getApplicationDocumentsDirectory()).path;
    _assetsDir = '$rootDir/$directory';
  }

  @override
  Future<bool> assetsDirAlreadyExists() async => await Directory(_assetsDir!).exists();

  @override
  Future<bool> assetsFileExists(String file) async => await File('$_assetsDir/$file').exists();

  @override
  Future clearAssets() async {
    bool assetsDirExists = await assetsDirAlreadyExists();

    if (!assetsDirExists) return;

    await Directory(_assetsDir!).delete(recursive: true);
  }

  @override
  Future startDownload({
    required String assetsUrl,
    Function(double)? onProgress,
    Function(Exception)? onError,
    Function? onComplete,
  }) async {
    try {
      if (assetsUrl.isEmpty) {
        throw DownloadAssetsException("AssetUrl param can't be empty");
      }

      await clearAssets();
      await Directory(_assetsDir!).create();
      String fullPath = '$_assetsDir/assets.zip';
      double totalProgress = 0;

      if (onProgress != null) onProgress(0);

      await Dio().download(
        assetsUrl,
        fullPath,
        options: Options(
          headers: {HttpHeaders.acceptEncodingHeader: "*"},
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total * 100);
            totalProgress = progress - (progress * 0.2);
          }

          if (onProgress != null) onProgress(totalProgress <= 0 ? 0 : totalProgress);
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

          if (onProgress != null) onProgress(totalProgress);
          print(filename);
        }
      }

      if (onProgress != null && totalProgress != 100) onProgress(100);

      if (onComplete != null) onComplete();
    } catch (e) {
      DownloadAssetsException downloadAssetsException = DownloadAssetsException(e.toString());

      if (onError != null)
        onError(downloadAssetsException);
      else
        throw downloadAssetsException;
    }
  }
}
