import 'package:download_assets/src/managers/file/file_manager_impl.dart';
import 'package:download_assets/src/managers/http/custom_http_client_impl.dart';

import 'download_assets_controller_impl.dart';

abstract class DownloadAssetsController {
  factory DownloadAssetsController({String directory = 'assets'}) => createObject(
        fileManager: FileManagerImpl(),
        customHttpClient: CustomHttpClientImpl(),
      );

  ///Directory that keeps all assets
  String? get assetsDir;

  // /// Just set the assets directory based on getApplicationPath
  // /// [directoryPath] -> Specify the local directory for your files. If it wasn't set a folder named 'assets' will be used.
  // Future setAssetsDirectory({String directoryPath = 'assets'});

  /// If assets directory was already created it assumes that the content was already downloaded.
  Future<bool> assetsDirAlreadyExists();

  /// It checks if file already exists
  /// [file] -> full path to file
  Future<bool> assetsFileExists(String file);

  /// Clear all download assets, if it already exists on local storage.
  Future clearAssets();

  /// Start download of your content to local storage, uncompress all data and delete
  /// the compressed file.
  /// [assetsUrl] -> Specify the url for your compressed file. (http://{YOUR_DOMAIN}:{FILE_NAME}.zip
  /// [onProgress] -> It's not required. If you provide this callback it will be called after each iteration
  /// returning the actual progress
  /// [onError] -> It's not required. If you provider this callback it will be called when any exception to occur
  /// [onComplete] -> It's not required. Called if the progress was completed with success
  Future startDownload({
    required String assetsUrl,
    String directoryPath,
    String zippedFile,
    required Function(double) onProgress,
    required Function onComplete,
  });
}
