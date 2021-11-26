import 'package:dio/dio.dart';

abstract class CustomHttpClient {
  Future<Response> download(
    String urlPath,
    savePath, {
    ProgressCallback? onReceiveProgress,
  });
}
