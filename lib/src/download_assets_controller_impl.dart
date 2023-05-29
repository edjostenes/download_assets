import 'package:path/path.dart';

import 'download_assets_controller.dart';
import 'exceptions/download_assets_exception.dart';
import 'managers/file/file_manager.dart';
import 'managers/http/custom_http_client.dart';

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
  late FileManager fileManager;
  late CustomHttpClient customHttpClient;

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
      final totalProgressPerFile = 100 / assetsUrls.length;
      await fileManager.createDirectory(_assetsDir!);

      for (var i = 0; i < assetsUrls.length; i++) {
        final assetsUrl = assetsUrls[i];
        var currentMaxProgress = totalProgressPerFile * (i + 1);

        if (currentMaxProgress > 100) {
          currentMaxProgress = 100;
        }

        // file extension and name
        final urlFile = fileManager.createFile(assetsUrl);
        final fileName = basename(urlFile.path);
        final fileExtension = extension(urlFile.path);
        final isCompressed = fileExtension.contains('zip');
        // -------------------------

        // downloading file
        final fullPath = '$_assetsDir/$fileName';
        await customHttpClient.download(
          assetsUrl,
          fullPath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total * 100;

              /// It's not required reduce the percentage that will be used to uncompress file
              /// when it's not an compressed file
              final progressLessCompressionTime =
                  progress - (isCompressed ? (progress * 0.2) : 0);

              if (progressLessCompressionTime >= currentMaxProgress) {
                totalProgress = currentMaxProgress;
              } else {
                totalProgress += progressLessCompressionTime;
              }
            }

            if (totalProgress < 100) {
              onProgress?.call(totalProgress);
            }
          },
          requestExtraHeaders: requestExtraHeaders,
          requestQueryParams: requestQueryParams,
        );
        // -----------------

        // creating file
        final zipFile = fileManager.createFile(fullPath);

        if (!isCompressed) {
          continue;
        }
        // -----------------

        //uncompressing
        final bytes = fileManager.readAsBytesSync(zipFile);
        final archive = fileManager.decodeBytes(bytes);
        await fileManager.deleteFile(zipFile);
        final totalFiles = archive.isNotEmpty ? archive.length.toDouble() : 20;

        ///amount that will be increased by file inside the archive
        ///proportional to the max value progress
        final increment = (20 / totalFiles) * (1 / assetsUrls.length);

        for (final file in archive) {
          final filename = '$_assetsDir/${file.name}';

          if (!file.isFile) {
            continue;
          }

          var outFile = fileManager.createFile(filename);
          outFile = await fileManager.createFileRecursively(outFile);
          await fileManager.writeAsBytes(outFile, file.content);
          totalProgress += increment;

          if (totalProgress < 100) {
            onProgress?.call(totalProgress);
          }
        }
        // -----------------
      }

      if (totalProgress != 100) {
        onProgress?.call(100);
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
