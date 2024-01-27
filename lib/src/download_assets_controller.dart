import 'package:path/path.dart';

import '../download_assets.dart';
import 'managers/custom_http_client.dart';
import 'managers/file_manager.dart';

const _threshold = 98.0;
const _maxTotal = 100.0;

abstract interface class DownloadAssetsController {
  factory DownloadAssetsController() => _DownloadAssetsControllerImpl(
        fileManager: FileManagerImpl(),
        customHttpClient: CustomHttpClientImpl(),
      );

  /// Initialization method for setting up the assetsDir, which is required to be called during app initialization.
  /// [assetDir] -> Not required. Path to directory where your zipFile will be downloaded and unzipped (default value is getApplicationPath + assets)
  /// [useFullDirectoryPath] -> Not required (default value is false). If this is true the getApplicationPath won't be used (make sure that the app has to write permission and it is a valid path)
  Future init({
    String assetDir = 'assets',
    bool useFullDirectoryPath = false,
  });

  ///Directory that keeps all assets
  String? get assetsDir;

  /// If assets directory was already created it assumes that the content was already downloaded.
  Future<bool> assetsDirAlreadyExists();

  /// It checks if file already exists
  /// [file] -> full path to file
  Future<bool> assetsFileExists(String file);

  /// Clear all download assets, if it already exists on local storage.
  Future clearAssets();

  /// Start the download of your content to local storage, uncompress all data and delete
  /// the compressed file. It's not required be compressed file.
  /// [assetsUrls] -> A list of URLs representing each file to be downloaded. (http://{YOUR_DOMAIN}:{FILE_NAME}.{EXTENSION})
  /// [uncompressDelegates] -> An optional list of [UncompressDelegate] objects responsible for handling asset decompression, if needed.
  /// If the [uncompressDelegates] list is empty, the [UnzipDelegate] class is automatically added as a delegate for ZIP file decompression.
  /// [onProgress] -> It's not required. Called after each iteration returning the current progress
  /// [onCancel] -> Cancel the download (optional)
  /// [requestQueryParams] -> Query params to be used in the request (optional)
  /// [requestExtraHeaders] -> Extra headers to be added in the request (optional)
  Future startDownload({
    required List<String> assetsUrls,
    List<UncompressDelegate> uncompressDelegates = const [UnzipDelegate()],
    Function(double)? onProgress,
    Function()? onCancel,
    Map<String, dynamic>? requestQueryParams,
    Map<String, String> requestExtraHeaders = const {},
  });

  /// Cancel the download
  void cancelDownload();
}

final class _DownloadAssetsControllerImpl implements DownloadAssetsController {
  _DownloadAssetsControllerImpl({required this.fileManager, required this.customHttpClient});

  String? _assetsDir;
  final FileManager fileManager;
  final CustomHttpClient customHttpClient;

  @override
  String? get assetsDir => _assetsDir;

  @override
  Future init({
    String assetDir = 'assets',
    bool useFullDirectoryPath = false,
  }) async {
    if (useFullDirectoryPath) {
      _assetsDir = assetDir;
      return;
    }

    final rootDir = await fileManager.getApplicationPath();
    _assetsDir = '$rootDir/$assetDir';
  }

  @override
  Future<bool> assetsDirAlreadyExists() async {
    assert(assetsDir != null, 'DownloadAssets has not been initialized. Call init method first');
    return await fileManager.directoryExists(_assetsDir!);
  }

  @override
  Future<bool> assetsFileExists(String file) async {
    assert(assetsDir != null, 'DownloadAssets has not been initialized. Call init method first');
    return await fileManager.fileExists('$_assetsDir/$file');
  }

  @override
  Future clearAssets() async {
    final assetsDirExists = await assetsDirAlreadyExists();

    if (!assetsDirExists) {
      return;
    }

    await fileManager.deleteDirectory(_assetsDir!);
  }

  @override
  Future startDownload({
    required List<String> assetsUrls,
    List<UncompressDelegate> uncompressDelegates = const [UnzipDelegate()],
    Function(double)? onProgress,
    Function()? onCancel,
    Map<String, dynamic>? requestQueryParams,
    Map<String, String> requestExtraHeaders = const {},
  }) async {
    assert(assetsDir != null, 'DownloadAssets has not been initialized. Call init method first');
    assert(assetsUrls.isNotEmpty, "AssetUrl param can't be empty");

    try {
      var totalProgress = 0.0;
      onProgress?.call(totalProgress);
      await fileManager.createDirectory(_assetsDir!);

      for (final assetsUrl in assetsUrls) {
        final fileName = basename(assetsUrl);
        final fileExtension = extension(assetsUrl);
        final fullPath = '$_assetsDir/$fileName';
        var previousProgress = 0.0;
        await customHttpClient.download(
          assetsUrl,
          fullPath,
          onReceiveProgress: (received, total) {
            if (total == -1) {
              return;
            }

            final progress = (received / total) * _maxTotal;
            final increment = progress - previousProgress;
            totalProgress += increment;
            previousProgress = progress;

            if (totalProgress >= _threshold || increment <= 0.1) {
              return;
            }

            onProgress?.call(totalProgress);
          },
          requestExtraHeaders: requestExtraHeaders,
          requestQueryParams: requestQueryParams,
        );

        for (final delegate in uncompressDelegates) {
          if (delegate.extension != fileExtension) {
            continue;
          }

          await delegate.uncompress(fullPath, _assetsDir!);
          break;
        }
      }

      if (totalProgress >= _threshold) {
        onProgress?.call(_maxTotal);
      }
    } on DownloadAssetsException catch (e) {
      if (e.downloadCancelled) {
        onCancel?.call();
        return;
      }

      rethrow;
    } on Exception catch (e) {
      throw DownloadAssetsException(e.toString(), exception: e);
    }
  }

  @override
  void cancelDownload() => customHttpClient.cancel();
}
