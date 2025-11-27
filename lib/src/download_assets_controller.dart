import 'download_assets_controller_impl.dart';
import 'managers/file/file_manager_impl.dart';
import 'managers/http/custom_http_client_impl.dart';
import 'uncompress_delegate/uncompress_delegate.dart';

class AssetUrl {
  const AssetUrl({required this.url, this.fileName});

  final String url;
  final String? fileName;
}

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

  /// Directory that keeps all assets
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
  /// [onStartUnzipping] -> Called right before the start of the uncompressing process.
  /// [onProgress] -> It's not required. Called after each iteration returning the current progress.
  /// The double parameter ranges from 0 to 1, where 1 indicates the completion of the download process.
  /// [onDone] -> Called when all files have been downloaded and uncompressed.
  /// [onCancel] -> Cancel the download (optional)
  /// [requestQueryParams] -> Query params to be used in the request (optional)
  /// [requestExtraHeaders] -> Extra headers to be added in the request (optional)
  /// [checkSize] -> Speicifies if the size of the file should be checked first before starting download
  Future startDownload({
    required List<AssetUrl> assetsUrls,
    List<UncompressDelegate> uncompressDelegates = const [UnzipDelegate()],
    Function(double)? onProgress,
    Function()? onStartUnzipping,
    Function()? onCancel,
    Function()? onDone,
    Map<String, dynamic>? requestQueryParams,
    Map<String, String> requestExtraHeaders = const {},
    bool checkSize = true,
  });

  /// Cancel the download
  void cancelDownload();
}
