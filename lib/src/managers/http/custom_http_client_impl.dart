import 'dart:io';

import 'package:dio/dio.dart';

import 'custom_http_client.dart';

class CustomHttpClientImpl implements CustomHttpClient {
  @override
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async =>
      await Dio().download(
        urlPath,
        savePath,
        options: Options(
          headers: {HttpHeaders.acceptEncodingHeader: '*'},
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: onReceiveProgress,
      );
}
