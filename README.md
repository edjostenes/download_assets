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
    * zippedFile: Zipped file that will be created (optional, default value is 'assets.zip').
* clearAssets - Clear all downloaded assets from local storage.
* assetsDir - Path to the files unzipped.
* assetsDirAlreadyExists - Returns true if the assetsDir path exists.
* assetsFileExists - Return true if the file exists.

# Example

You can find an example here: https://github.com/edjostenes/download_assets/tree/master/example
