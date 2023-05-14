[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

# About download_assets

This package downloads a zipped file and unzips to local storage all assets that are not included in your app. Some files, like images, sometimes, must not be included in your build.

# Supported platforms

* iOS
* Android
* Windows

# Methods

* init - Method that sets up the assetsDir and must be called on the app initialization.
* startDownload - It start the assets download.
    * assetsUrl: Full URL to the zipped file.
    * onProgress: It returns the download progress (optional).
    * onCancel: Callback called after cancels the download (optional).
    * zippedFile: Zipped file that will be created (optional, default value is 'assets.zip').
    * requestQueryParams: Query params to be used in the request (optional).
    * requestExtraHeaders: Extra headers to be added in the request (optional).
* cancelDownload - Cancel the download (optional). 
* clearAssets - Clear all downloaded assets from local storage.
* assetsDir - Path to the files unzipped.
* assetsDirAlreadyExists - Returns true if the assetsDir path exists.
* assetsFileExists - Return true if the file exists.

# Example

You can find an example here: https://github.com/edjostenes/download_assets/tree/master/example
