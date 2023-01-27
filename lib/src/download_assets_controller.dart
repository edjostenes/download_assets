import 'download_assets_controller_impl.dart';
import 'managers/file/file_manager_impl.dart';
import 'managers/http/custom_http_client_impl.dart';

abstract class DownloadAssetsController {
  factory DownloadAssetsController({String directory = 'assets'}) =>
      createObject(
        fileManager: FileManagerImpl(),
        customHttpClient: CustomHttpClientImpl(),
      );

  /// Initialize the package setting up the assetPath.
  /// It must be called to set up the assetDir path.
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

  /// Start download of your content to local storage, uncompress all data and delete
  /// the compressed file.
  /// [assetsUrl] -> Specify the url for your compressed file. (http://{YOUR_DOMAIN}:{FILE_NAME}.zip
  /// [onProgress] -> It's not required. Called after each iteration returning the current progress
  /// [onComplete] -> It's not required. Called when the progress is completed with success
  /// [zippedFile] -> Zipped file's name (default value is assets.zip)
  Future startDownload({
    required String assetsUrl,
    Function(double)? onProgress,
    String zippedFile = 'assets.zip',
  });
}
