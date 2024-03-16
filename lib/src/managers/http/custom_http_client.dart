import 'package:dio/dio.dart';

abstract interface class CustomHttpClient {
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? requestQueryParams,
    Map<String, String> requestExtraHeaders = const {},
  });

  void cancel();

  Future<int> checkSize(String urlPath);
}
