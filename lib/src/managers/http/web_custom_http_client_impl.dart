import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../download_assets.dart';
import '../file/file_manager.dart';
import 'custom_http_client.dart';

class WebCustomHttpClientImpl implements CustomHttpClient {
  WebCustomHttpClientImpl({required this.fileManager});

  CancelToken? _cancelToken;
  final FileManager fileManager;

  @override
  void cancel() => _cancelToken?.cancel();

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
  Future<void> download(String urlPath, String savePath,
      {ProgressCallback? onReceiveProgress,
      Map<String, dynamic>? requestQueryParams,
      Map<String, String> requestExtraHeaders = const {}}) async {
    _cancelToken = CancelToken();
    try {
      final response = await Dio().get<Uint8List>(
        urlPath,
        queryParameters: requestQueryParams,
        options: Options(
          responseType: ResponseType.bytes,
          headers: requestExtraHeaders,
        ),
        onReceiveProgress: onReceiveProgress,
        cancelToken: _cancelToken,
      );

      if (response.data == null) {
        throw DownloadAssetsException('No data received');
      }

      await fileManager.writeFile(savePath, Uint8List.fromList(response.data! as List<int>));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw DownloadAssetsException(e.toString(), exception: e, downloadCancelled: true);
      }

      rethrow;
    } finally {
      _cancelToken = null;
    }
  }
}
