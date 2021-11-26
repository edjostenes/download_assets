import 'package:download_assets/src/download_assets_controller.dart';
import 'package:download_assets/src/exceptions/download_assets_exception.dart';
import 'package:download_assets/src/managers/file/file_manager.dart';
import 'package:download_assets/src/managers/http/custom_http_client.dart';

DownloadAssetsController createObject({
  required String directoryPath,
  required FileManager fileManager,
  required CustomHttpClient customHttpClient,
}) =>
    DownloadAssetsControllerImpl(
      directoryPath: directoryPath,
      fileManager: fileManager,
      customHttpClient: customHttpClient,
    );

class DownloadAssetsControllerImpl implements DownloadAssetsController {
  late String _assetsDir;
  late FileManager _fileManager;
  late CustomHttpClient _customHttpClient;

  @override
  String get assetsDir => _assetsDir;

  DownloadAssetsControllerImpl({
    required String directoryPath,
    required FileManager fileManager,
    required CustomHttpClient customHttpClient,
  }) {
    _fileManager = fileManager;
    _customHttpClient = customHttpClient;
    _init(directoryPath);
  }

  void _init(String directoryPath) async {
    String rootDir = await _fileManager.getApplicationPath();
    _assetsDir = '$rootDir/$directoryPath';
  }

  @override
  Future<bool> assetsDirAlreadyExists() async => await _fileManager.directoryExists(_assetsDir);

  @override
  Future<bool> assetsFileExists(String file) async => await _fileManager.fileExists('$_assetsDir/$file');

  @override
  Future clearAssets() async {
    bool assetsDirExists = await assetsDirAlreadyExists();

    if (!assetsDirExists) return;

    await _fileManager.deleteDirectory(_assetsDir);
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
      await _fileManager.createDirectory(_assetsDir);
      String fullPath = '$_assetsDir/assets.zip';
      double totalProgress = 0;

      if (onProgress != null) onProgress(0);

      await _customHttpClient.download(
        assetsUrl,
        fullPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total * 100);
            totalProgress = progress - (progress * 0.2);
          }

          if (onProgress != null) onProgress(totalProgress <= 0 ? 0 : totalProgress);
        },
      );

      var zipFile = _fileManager.createFile(fullPath);
      var bytes = zipFile.readAsBytesSync();
      var archive = _fileManager.decodeBytes(bytes);
      await _fileManager.deleteFile(zipFile);
      double totalFiles = archive.length > 0 ? archive.length.toDouble() : 20;
      double increment = 20 / totalFiles;

      for (var file in archive) {
        var filename = '$_assetsDir/${file.name}';

        if (file.isFile) {
          var outFile = _fileManager.createFile(filename);
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
          totalProgress += increment;

          if (onProgress != null) onProgress(totalProgress);
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
