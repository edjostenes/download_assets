/// Exception thrown during asset download operations in [DownloadAssetsControllerImpl].
///
/// This exception provides information about any errors that occur during asset downloads.
/// It includes an optional underlying [exception] that caused the error and a boolean flag [downloadCancelled]
/// indicating if the download was explicitly cancelled by the user.
///
/// Example usage:
/// ```dart
/// try {
///   // Perform asset download operation
/// } on DownloadAssetsException catch (e) {
///   if (e.downloadCancelled) {
///     // Handle download cancellation
///   } else {
///     // Handle other download-related errors
///   }
/// }
/// ```
class DownloadAssetsException implements Exception {
  /// Creates a new instance of [DownloadAssetsException].
  ///
  /// The [message] parameter represents the error message to be associated with the exception.
  /// The optional [exception] parameter represents the underlying exception that caused the error.
  /// The optional [downloadCancelled] parameter indicates if the download was explicitly cancelled by the user.
  DownloadAssetsException(
    this._message, {
    this.exception,
    this.stackTrace,
    this.downloadCancelled = false,
  });

  DownloadAssetsException.noHeaders()
      : _message = 'Fail to get HTTP headers',
        exception = null,
        stackTrace = null,
        downloadCancelled = false;

  DownloadAssetsException.noContentLength()
      : _message = 'Fail to get content length from server',
        exception = null,
        stackTrace = null,
        downloadCancelled = false;

  /// The underlying exception that caused the error.
  final Exception? exception;

  final StackTrace? stackTrace;

  /// Indicates if the download was explicitly cancelled by the user.
  final bool downloadCancelled;

  final String _message;

  @override
  String toString() => exception?.toString() ?? _message;
}
