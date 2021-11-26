import 'package:dio/dio.dart';

abstract class CustomHttpClient {
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  });
}
