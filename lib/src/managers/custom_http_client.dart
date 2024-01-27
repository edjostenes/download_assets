import 'dart:io';

import 'package:dio/dio.dart';

import '../exceptions/download_assets_exception.dart';

abstract class CustomHttpClient {
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? requestQueryParams,
    Map<String, String> requestExtraHeaders = const {},
  });

  void cancel();
}

class CustomHttpClientImpl implements CustomHttpClient {
  CancelToken? _cancelToken;

  @override
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? requestQueryParams,
    Map<String, String> requestExtraHeaders = const {},
  }) async {
    try {
      _cancelToken = CancelToken();
      final headers = {HttpHeaders.acceptEncodingHeader: '*'};

      if (requestExtraHeaders.isNotEmpty) {
        headers.addAll(requestExtraHeaders);
      }

      return await Dio().download(
        urlPath,
        savePath,
        cancelToken: _cancelToken,
        queryParameters: requestQueryParams,
        options: Options(
          headers: requestExtraHeaders,
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw DownloadAssetsException(
          e.toString(),
          exception: e,
          downloadCancelled: true,
        );
      }

      rethrow;
    }
  }

  @override
  void cancel() => _cancelToken?.cancel();
}
