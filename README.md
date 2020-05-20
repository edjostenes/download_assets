# download_assets
This package download and uncompress to local storage all assets that are not included in your app.

# Supported platforms
* iOS
* Android

# Methods
* startDownload - It start the assets download.
  * assetsUrl -> Full url to zipped file
  * onProgress -> It returns the download progress (optional)
  * onError -> Called when any errors ocurr (optional)
  * onComplete -> Called when the download is completed (optional)  
* clearAssets - Clear all downloaded assets from local storage.
* assets Downloaded - Returns true if the assets were already downloaded, otherwise it' returns false.
