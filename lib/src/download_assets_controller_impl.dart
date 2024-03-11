import 'package:path/path.dart';
import 'package:dio/dio.dart';

import 'download_assets_controller.dart';
import 'exceptions/download_assets_exception.dart';
import 'managers/file/file_manager.dart';
import 'managers/http/custom_http_client.dart';
import 'uncompress_delegate/uncompress_delegate.dart';

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
  double minIncrement = 0.01;
  int _totalSize = -1;
  int _downloadedSize = 0;

  @override
  String? get assetsDir => _assetsDir;

  @override
  Future init({
    String assetDir = 'assets',
    bool useFullDirectoryPath = false,
    double minThreshold = 0.01,
  }) async {
    minIncrement = minThreshold;
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
    Function()? onStartUnziping,
    Function()? onCancel,
    Function()? onDone,
    Map<String, dynamic>? requestQueryParams,
    Map<String, String> requestExtraHeaders = const {},
  }) async {
    assert(assetsDir != null,
        'DownloadAssets has not been initialized. Call init method first');
    assert(assetsUrls.isNotEmpty, "AssetUrl param can't be empty");

    try {
      onProgress?.call(0.0);
      await fileManager.createDirectory(_assetsDir!);
      final List<({String assetUrl, String fullPath})> assets = [];
      _downloadedSize = 0;

      for (final assetsUrl in assetsUrls) {
        final fileName = basename(assetsUrl);
        final fullPath = '$_assetsDir/$fileName';
        assets.add((assetUrl: assetsUrl, fullPath: fullPath));
        final size = await customHttpClient.checkSize(assetsUrl);
        _totalSize += size;
      }

      final List<Future<Response>> responses = [];
      Map<String, int> downloadedBytesPerAsset = {};
      for (final asset in assets) {
        final response = customHttpClient.download(
          asset.assetUrl,
          asset.fullPath,
          onReceiveProgress: (int received, int total) {
            if (total == -1 || received <= 0) {
              return;
            }

            int previousReceived = downloadedBytesPerAsset[asset.fullPath] ?? 0;
            _downloadedSize += received - previousReceived;
            downloadedBytesPerAsset[asset.fullPath] = received;

            final progress = _downloadedSize / _totalSize;

            onProgress?.call(progress);
          },
          requestExtraHeaders: requestExtraHeaders,
          requestQueryParams: requestQueryParams,
        );
        responses.add(response);
      }

      await Future.wait(responses);
      onStartUnziping?.call();

      for (final asset in assets) {
        final fileExtension = extension(asset.assetUrl);
        for (final delegate in uncompressDelegates) {
          if (delegate.extension != fileExtension) {
            continue;
          }
          await delegate.uncompress(asset.fullPath, _assetsDir!);
          break;
        }
      }

      onDone?.call();
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
