import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

import 'download_assets_controller.dart';
import 'exceptions/download_assets_exception.dart';
import 'managers/file/file_manager.dart';
import 'managers/http/custom_http_client.dart';
import 'uncompress_delegate/uncompress_delegate.dart';
import 'uncompress_delegate/web_uncompress_delegate.dart';

DownloadAssetsController createObject({required FileManager fileManager, required CustomHttpClient customHttpClient}) =>
    DownloadAssetsControllerImpl(fileManager: fileManager, customHttpClient: customHttpClient);

class DownloadAssetsControllerImpl implements DownloadAssetsController {
  DownloadAssetsControllerImpl({required this.fileManager, required this.customHttpClient});

  String? _assetsDir;
  final FileManager fileManager;
  final CustomHttpClient customHttpClient;

  @override
  String? get assetsDir => _assetsDir;

  @override
  Future init({String assetDir = 'assets', bool useFullDirectoryPath = false}) async {
    if (useFullDirectoryPath) {
      _assetsDir = assetDir;
      return;
    }

    final rootDir = await fileManager.getApplicationPath();

    if (kIsWeb || kIsWasm) {
      _assetsDir = rootDir;
    } else {
      _assetsDir = '$rootDir/$assetDir';
    }
  }

  @override
  Future<Uint8List?> getAssetFromWeb(String fileName) {
    assert(kIsWeb || kIsWasm, 'This method is only available on web');
    return fileManager.readFile(fileName);
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
    required List<AssetUrl> assetsUrls,
    List<UncompressDelegate> uncompressDelegates = const [kIsWeb ? WebUncompressDelegate() : UnzipDelegate()],
    Function(double)? onProgress,
    Function()? onStartUnzipping,
    Function()? onCancel,
    Function()? onDone,
    Map<String, dynamic>? requestQueryParams,
    Map<String, String> requestExtraHeaders = const {},
    bool checkSize = true,
  }) async {
    assert(assetsDir != null, 'DownloadAssets has not been initialized. Call init method first');
    assert(assetsUrls.isNotEmpty, "AssetUrl param can't be empty");

    try {
      onProgress?.call(0.0);
      await fileManager.createDirectory(_assetsDir!);
      var totalSize = -1;
      var downloadedSize = 0;
      final assets = <({String assetUrl, String fullPath, String extension})>[];

      for (final assetUrl in assetsUrls) {
        final fileName = assetUrl.fileName ?? basename(assetUrl.url);
        final fullPath = '$_assetsDir/$fileName';
        assets.add((assetUrl: assetUrl.url, fullPath: fullPath, extension: extension(fileName)));

        if (checkSize) {
          final size = await customHttpClient.checkSize(assetUrl.url);
          totalSize += size;
        }
      }

      final downloadedBytesPerAsset = <String, int>{};

      for (final asset in assets) {
        await customHttpClient.download(
          asset.assetUrl,
          asset.fullPath,
          onReceiveProgress: (int received, int total) {
            if (!checkSize) {
              return;
            }

            final previousReceived = downloadedBytesPerAsset[asset.fullPath] ?? 0;
            downloadedSize += received - previousReceived;
            downloadedBytesPerAsset[asset.fullPath] = received;

            final progress = totalSize > 0 ? downloadedSize / totalSize : 0.0;
            onProgress?.call(progress);
          },
          requestExtraHeaders: requestExtraHeaders,
          requestQueryParams: requestQueryParams,
        );
      }

      onStartUnzipping?.call();

      for (final asset in assets) {
        final fileExtension = asset.extension;

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
    } on Exception catch (e, st) {
      throw DownloadAssetsException(e.toString(), exception: e, stackTrace: st);
    }
  }

  @override
  void cancelDownload() => customHttpClient.cancel();
}
