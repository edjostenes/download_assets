import 'package:path/path.dart';

import 'download_assets_controller.dart';
import 'exceptions/download_assets_exception.dart';
import 'managers/file/file_manager.dart';
import 'managers/http/custom_http_client.dart';
import 'uncompress_delegate/uncompress_delegate.dart';

const _threshold = 98.0;
const _maxTotal = 100.0;

DownloadAssetsController createObject({
  required FileManager fileManager,
  required CustomHttpClient customHttpClient,
}) =>
    DownloadAssetsControllerImpl(
      fileManager: fileManager,
      customHttpClient: customHttpClient,
    );

class DownloadAssetsControllerImpl implements DownloadAssetsController {
  DownloadAssetsControllerImpl({
    required this.fileManager,
    required this.customHttpClient,
  });

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
    assert(assetsDir != null,
        'DownloadAssets has not been initialized. Call init method first');
    return await fileManager.directoryExists(_assetsDir!);
  }

  @override
  Future<bool> assetsFileExists(String file) async {
    assert(assetsDir != null,
        'DownloadAssets has not been initialized. Call init method first');
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
    assert(assetsDir != null,
        'DownloadAssets has not been initialized. Call init method first');
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

            final percent = received / total;
            final progress = percent * _maxTotal;
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
