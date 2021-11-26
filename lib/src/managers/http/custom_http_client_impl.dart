import 'dart:io';

import 'package:dio/dio.dart';
import 'package:download_assets/src/managers/http/custom_http_client.dart';

class CustomHttpClientImpl implements CustomHttpClient {
  @override
  Future<Response> download(
    String urlPath,
    savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    return await Dio().download(
      urlPath,
      savePath,
      options: Options(
        headers: {HttpHeaders.acceptEncodingHeader: "*"},
        responseType: ResponseType.bytes,
      ),
      onReceiveProgress: onReceiveProgress,
    );
  }
}
