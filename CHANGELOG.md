## 3.2.0 - March 14, 2024
* Added new callbacks (onStartUnziping and onDone) on startDownload method
* The double parameter, in the *onProgress* callback, ranges from 0 to 1, where 1 indicates the completion of the download process

## 3.1.1 - July 12, 2023

* Added the optional parameter uncompressDelegates to the startDownload() method.
    * Description: This parameter allows providing a list of custom decompression delegates for the
      download process.Decompression delegates are responsible for implementing the logic to
      uncompress different types of files, such as ZIP, RAR, etc. By providing a list of delegates,
      it becomes possible to support multiple file formats during the download.
    * Default value: [UnzipDelegate()]
* Created UnzipDelegate to decompress .ZIP files

## 3.1.0 - May 29, 2023

* No longer necessary to specify whether the downloaded file is compressed.

### Breaking Changes

* The assetsUrl parameter has been updated from a string to a list of strings.

## 3.0.4 - May 14, 2023

* Added feature to cancel the download
* Now allows send queryParameters and extra headers in the request

## 3.0.3 - January 27, 2023

* Lint applied to project
* All dependencies updated

## 3.0.0 - December 27, 2021

* BREAKING REFACTOR: It's no more required the onProgress callback and was removed the onComplete
  callback;
* All async code from the constructor was removed;
* Removed setAssetDir method and added init method. (check de documentation or example to see how to
  use it)

## 2.1.0 - November 26, 2021

* BREAKING REFACTOR: It was refactored all architecture
* No more static methods/getters
* Updated all dependencies

## 2.0.0 - June 10, 2021

* Project migrated to null-safety

## 1.0.4 - September 25, 2020

* Allow asset directory to be specified

## 1.0.3 - May 20, 2020

* Little adjustments

## 1.0.2 - May 19, 2020

* Added getter to local directory (assetsDir)
* Added example file
* Renamed progressCallback and errorCallback to onProgress and onError
* Added onComplete callback

## 1.0.1 - May 18, 2020

* First version.