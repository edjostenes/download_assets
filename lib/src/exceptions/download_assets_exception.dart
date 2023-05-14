class DownloadAssetsException implements Exception {
  DownloadAssetsException(
    this._message, {
    this.exception,
    this.downloadCancelled = false,
  });

  final Exception? exception;
  final bool downloadCancelled;
  final String _message;

  @override
  String toString() => exception?.toString() ?? _message;
}
