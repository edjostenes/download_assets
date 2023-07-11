import 'download_assets_controller_impl.dart';
import 'managers/file/file_manager_impl.dart';
import 'managers/http/custom_http_client_impl.dart';
import 'uncompress_delegate/uncompress_delegate.dart';

abstract class DownloadAssetsController {
  factory DownloadAssetsController() => createObject(
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
  /// [onProgress] -> It's not required. Called after each iteration returning the current progress
  /// [onCancel] -> Cancel the download (optional)
  /// [requestQueryParams] -> Query params to be used in the request (optional)
  /// [requestExtraHeaders] -> Extra headers to be added in the request (optional)
  Future startDownload({
    required List<String> assetsUrls,
    List<UncompressDelegate> uncompressDelegates = const [],
    Function(double)? onProgress,
    Function()? onCancel,
    Map<String, dynamic>? requestQueryParams,
    Map<String, String> requestExtraHeaders = const {},
  });

  /// Cancel the download
  void cancelDownload();
}
