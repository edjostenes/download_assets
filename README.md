[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

# Download_assets

## About

The download_assets package is a powerful library that facilitates the process of downloading assets
into the application. With this library, you can easily download files, images, videos, and other
resources in your app, providing a smooth and efficient user experience.

<p align="center">
  <img src="https://media.giphy.com/media/SYDVx5BJFGrnSaPBtQ/giphy.gif">
</p>

## Features

### *init*

Init method for setting up the assetsDir, which is required to be called during app
initialization.

```dart
await downloadAssetsController.init();
```

### *startDownload*

Starts the asset download process.

* *assetsUrls*: A list of [AssetUrl] objects representing each file to be downloaded.
* *uncompressDelegates*: A list of custom decompression delegates for different types of file, such
  as ZIP, RAR, etc (optional).
* *onStartUnziping*: Called right before the start of the uncompressing process (optional).
* *onProgress*: It's not required. Called after each iteration returning the current progress (optional). The double parameter ranges from 0 to 1, where 1 indicates the completion of the download process.
* *onDone*: Called when all files have been downloaded and uncompressed (optional).
* *onCancel*: Cancels the ongoing download (optional).
* *requestQueryParams*: Query params to be used in the request (optional).
* *requestExtraHeaders*: Extra headers to be added in the request (optional).

```dart
await downloadAssetsController.startDownload(
    onCancel: () {
        //TODO: implement cancel here
    },
    assetsUrls: [
      AssetUrl(url: 'https://github.com/edjostenes/download_assets/raw/main/download/image_1.png'),
      AssetUrl(url: 'https://github.com/edjostenes/download_assets/raw/main/download/assets.zip'),
      AssetUrl(url: 'https://github.com/edjostenes/download_assets/raw/main/download/image_2.png'),
      AssetUrl(url: 'https://github.com/edjostenes/download_assets/raw/main/download/image_3.png'),
    ],
    onProgress: (progressValue) {
        //TODO: Implement progress here
    },
    onDone: () {
      //TODO: Implement progress here
    }
);
```

### *AssetUrl*

You can now specify the file name and extension with the AssetUrl class in case you don't have control over the URL format.

```dart
class AssetUrl {
  final String url;
  final String? fileName;

  AssetUrl({
    required this.url,
    this.fileName,
  });
}
```

### *clearAssets*

Remove all downloaded assets from local storage.

```dart
await downloadAssetsController.clearAssets();
```

### *assetsDir*

Path to the files.

```dart
File('${downloadAssetsController.assetsDir}/<file_name>.<file_extension>');
```

### *assetsDirAlreadyExists*

Returns **true** if the **assetsDir** path exists.

```dart
return await downloadAssetsController.assetsDirAlreadyExists();
```

### *assetsFileExists*

Return **true** if the file exists.

```dart
return await downloadAssetsController.assetsFileExists(<file_name>);
```

## Uncompress delegate

Uncompress delegates are responsible for implementing the logic to uncompress different types of
files, such as ZIP, RAR, etc. By providing a list of delegates, it becomes possible to support
multiple file formats during the download.

To implement your own uncompression delegate, you should implement the interface below.

```dart
/// Abstract class representing a delegate for asset decompression.
abstract class UncompressDelegate {
  const UncompressDelegate();

  /// Gets the file extension associated with the delegate.
  String get extension;

  /// uncompress the asset located at [compressedFilePath] to the specified [assetsDir].
  /// [compressedFilePath] -> The path to the compressed asset file.
  /// [assetsDir] -> The directory where the uncompressed asset should be stored.
  Future uncompress(String compressedFilePath, String assetsDir);
}
```

**Note**: This kind of delegate is essential for enabling the download process to handle various
file formats by implementing the necessary decompression logic. This flexibility allows users to
download and work with a wide range of compressed file types effortlessly. **UnzipDelegate()**, is
already included, which handles the decompression of ZIP files.

## Example

You can find an example here: https://github.com/edjostenes/download_assets/tree/master/example

## Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvement,
please create an issue on the GitHub repository.
