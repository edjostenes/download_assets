class DownloadAssetsException implements Exception {
  
  final Exception? exception;
  final String _message;

  DownloadAssetsException(this._message, {this.exception});

  String toString() => exception?.toString() ?? _message;

}