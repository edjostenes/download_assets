[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

# Download_assets

## About

The download_assets package is a powerful library that facilitates the process of downloading assets
into the application. With this library, you can easily download files, images, videos, and other
resources in your app, providing a smooth and efficient user experience.

## Features

### init

Initialization method for setting up the assetsDir, which is required to be called during app initialization.

### startDownload

Starts the asset download process.

* 'assetsUrls': A list of URLs representing each file to be downloaded.
* 'onProgress': Optional callback function that provides download progress information.
* 'onCancel': Cancels the ongoing download.

```
await downloadAssetsController.startDownload(
    onCancel: () {
        //TODO: implement cancel here
    },
    assetsUrls: [
      'https://github.com/edjostenes/download_assets/raw/dev/download/assets.zip',
    ],
    onProgress: (progressValue) {
        //TODO: Implement progress here
    },
);
```

### clearAssets

Remove all downloaded assets from local storage.

### assetsDir

Path to the files.

### assetsDirAlreadyExists

Returns **true** if the **assetsDir** path exists.

### assetsFileExists

Return **true** if the file exists.

## Example

You can find an example here: https://github.com/edjostenes/download_assets/tree/master/example

## Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvement,
please create an issue on the GitHub repository.
