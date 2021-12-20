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
  /// [onProgress] -> It's required. Called after each iteration returning the current progress
  /// [onComplete] -> It's required. Called when the progress is completed with success
  /// [directoryPath] -> Path to directory where your zipFile will be downloaded and unzipped (default value is getApplicationPath + assets)
  /// [zippedFile] -> Zipped file's name (default value is assets.zip)
  /// [useFullDirectoryPath] -> If this is true the getApplicationPath won't be used (make sure that the app has to write permission and it is a valid path)
  Future startDownload({
    required String assetsUrl,
    required Function(double) onProgress,
    required Function onComplete,
    String directoryPath,
    String zippedFile,
    bool useFullDirectoryPath,
  });
}
