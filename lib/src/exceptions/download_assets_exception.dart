class DownloadAssetsException implements Exception {
  DownloadAssetsException(this._message, {this.exception});

  final Exception? exception;
  final String _message;

  @override
  String toString() => exception?.toString() ?? _message;
}
