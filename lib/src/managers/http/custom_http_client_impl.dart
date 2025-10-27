import 'dart:io';

import 'package:dio/dio.dart';

import '../../../download_assets.dart';
import 'custom_http_client.dart';

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
        options: Options(headers: headers, responseType: ResponseType.bytes),
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw DownloadAssetsException(e.toString(), exception: e, downloadCancelled: true);
      }

      rethrow;
    }
  }

  @override
  Future<int> checkSize(String urlPath) async {
    final response = await Dio().head(urlPath);
    final size = int.parse(response.headers.value('content-length') ?? '0');
    return size;
  }

  @override
  void cancel() => _cancelToken?.cancel();
}
