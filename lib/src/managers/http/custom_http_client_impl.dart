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
    final response = await Dio().head(
      urlPath,
      options: Options(
        headers: {
          HttpHeaders.acceptEncodingHeader: '*',
          'Cache-Control': 'no-cache',
        },
        responseType: ResponseType.plain,
        followRedirects: true,
        maxRedirects: 10,
        receiveDataWhenStatusError: true,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode != 200) {
      throw DownloadAssetsException.noHeaders();
    }

    final contentLength = response.headers.value(Headers.contentLengthHeader);

    if (contentLength == null) {
      throw DownloadAssetsException.noContentLength();
    }

    return int.parse(contentLength);
  }

  @override
  void cancel() => _cancelToken?.cancel();
}
