import 'package:download_assets/src/download_assets_controller.dart';
import 'package:download_assets/src/exceptions/download_assets_exception.dart';
import 'package:download_assets/src/managers/file/file_manager.dart';
import 'package:download_assets/src/managers/http/custom_http_client.dart';

DownloadAssetsController createObject({
  required FileManager fileManager,
  required CustomHttpClient customHttpClient,
}) =>
    DownloadAssetsControllerImpl(
      fileManager: fileManager,
      customHttpClient: customHttpClient,
    );

class DownloadAssetsControllerImpl implements DownloadAssetsController {
  String? _assetsDir;

  late FileManager fileManager;
  late CustomHttpClient customHttpClient;

  @override
  String? get assetsDir => _assetsDir;

  DownloadAssetsControllerImpl({
    required this.fileManager,
    required this.customHttpClient,
  });

  @override
  Future init({
    String assetDir = 'assets',
    bool useFullDirectoryPath = false,
  }) async {
    if (useFullDirectoryPath) {
      _assetsDir = assetDir;
    } else {
      String rootDir = await fileManager.getApplicationPath();
      _assetsDir = '$rootDir/$assetDir';
    }
  }

  @override
  Future<bool> assetsDirAlreadyExists() async {
    if (_assetsDir == null) {
      return false;
    }

    return await fileManager.directoryExists(_assetsDir!);
  }

  @override
  Future<bool> assetsFileExists(String file) async {
    if (_assetsDir == null) {
      return false;
    }

    return await fileManager.fileExists('$_assetsDir/$file');
  }

  @override
  Future clearAssets() async {
    bool assetsDirExists = await assetsDirAlreadyExists();

    if (!assetsDirExists) {
      return;
    }

    await fileManager.deleteDirectory(_assetsDir!);
  }

  @override
  Future startDownload({
    required String assetsUrl,
    Function(double)? onProgress,
    String zippedFile = 'assets.zip',
  }) async {
    try {
      if (assetsUrl.isEmpty) {
        throw DownloadAssetsException("AssetUrl param can't be empty");
      }

      if (_assetsDir == null) {
        throw DownloadAssetsException("DownloadAssets has not been initialized. Call init method first");
      }

      await fileManager.createDirectory(_assetsDir!);
      String fullPath = '$_assetsDir/$zippedFile';
      double totalProgress = 0;
      onProgress?.call(totalProgress);

      await customHttpClient.download(
        assetsUrl,
        fullPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total * 100);
            totalProgress = progress - (progress * 0.2);
          }

          onProgress?.call(totalProgress <= 0 ? 0 : totalProgress);
        },
      );

      var zipFile = fileManager.createFile(fullPath);
      var bytes = fileManager.readAsBytesSync(zipFile);
      var archive = fileManager.decodeBytes(bytes);
      await fileManager.deleteFile(zipFile);
      double totalFiles = archive.length > 0 ? archive.length.toDouble() : 20;
      double increment = 20 / totalFiles;

      for (var file in archive) {
        var filename = '$_assetsDir/${file.name}';

        if (file.isFile) {
          var outFile = fileManager.createFile(filename);
          outFile = await fileManager.createFileRecursively(outFile);
          await fileManager.writeAsBytes(outFile, file.content);
          totalProgress += increment;
          onProgress?.call(totalProgress);
        }
      }

      if (totalProgress != 100) {
        onProgress?.call(100);
      }
    } on Exception catch (e) {
      throw DownloadAssetsException(
        e.toString(),
        exception: e,
      );
    }
  }
}
