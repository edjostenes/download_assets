import 'dart:io';

import 'package:dio/dio.dart';
import 'package:download_assets/download_assets.dart';
import 'package:download_assets/src/download_assets_controller_impl.dart';
import 'package:download_assets/src/managers/file/file_manager.dart';
import 'package:download_assets/src/managers/http/custom_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFileManager extends Mock implements FileManager {}

class MockCustomHttpClient extends Mock implements CustomHttpClient {}

class MockUnzipDelegate implements UncompressDelegate {
  @override
  String get extension => '';

  @override
  Future uncompress(String compressedFilePath, String assetsDir) async => null;
}

void main() {
  late FileManager fileManager;
  late CustomHttpClient customHttpClient;
  late DownloadAssetsController downloadAssetsController;
  final unzipDelegate = MockUnzipDelegate();

  setUp(() {
    fileManager = MockFileManager();
    customHttpClient = MockCustomHttpClient();
    downloadAssetsController = DownloadAssetsControllerImpl(
      fileManager: fileManager,
      customHttpClient: customHttpClient,
    );
    registerFallbackValue(unzipDelegate);
  });

  group('init', () {
    test(
      'Should initialize when init was called',
      () async {
        // given
        when(() => fileManager.getApplicationPath()).thenAnswer((invocation) async => '/root');

        // when
        await downloadAssetsController.init();

        // then
        expect(downloadAssetsController.assetsDir, '/root/assets');
        verify(() => fileManager.getApplicationPath()).called(1);
        verifyNoMoreInteractions(fileManager);
      },
    );

    test(
      'Should initialize when init was called and use full directory path',
      () async {
        // when
        await downloadAssetsController.init(useFullDirectoryPath: true);

        // then
        expect(downloadAssetsController.assetsDir, 'assets');
        verifyNever(() => fileManager.getApplicationPath());
      },
    );

    test(
      'Should initialize when init was called and use a different assetDir',
      () async {
        // when
        await downloadAssetsController.init(assetDir: '/root', useFullDirectoryPath: true);

        // then
        expect(downloadAssetsController.assetsDir, '/root');
        verifyNever(() => fileManager.getApplicationPath());
      },
    );
  });

  group('assetsDirAlreadyExists', () {
    setUp(
      () async {
        await downloadAssetsController.init(useFullDirectoryPath: true);
      },
    );

    test(
      'Should return true when assetsDirAlreadyExists was called',
      () async {
        // given
        when(() => fileManager.directoryExists(any())).thenAnswer((invocation) async => true);

        // when
        final result = await downloadAssetsController.assetsDirAlreadyExists();

        // then
        expect(result, true);
        verify(() => fileManager.directoryExists(any())).called(1);
        verifyNoMoreInteractions(fileManager);
      },
    );

    test(
      'Should return false when assetsDirAlreadyExists was called',
      () async {
        // given
        when(() => fileManager.directoryExists(any())).thenAnswer((invocation) async => false);

        // when
        final result = await downloadAssetsController.assetsDirAlreadyExists();

        // then
        expect(result, false);
        verify(() => fileManager.directoryExists(any())).called(1);
        verifyNoMoreInteractions(fileManager);
      },
    );
  });

  group('assetsFileExists', () {
    setUp(
      () async {
        await downloadAssetsController.init(useFullDirectoryPath: true);
      },
    );

    test(
      'Should return true when assetsFileExists was called',
      () async {
        // given
        when(() => fileManager.fileExists(any())).thenAnswer((invocation) async => true);

        // when
        final result = await downloadAssetsController.assetsFileExists('');

        // then
        expect(result, true);
        verify(() => fileManager.fileExists(any())).called(1);
        verifyNoMoreInteractions(fileManager);
      },
    );

    test(
      'Should return false when assetsFileExists was called',
      () async {
        // given
        when(() => fileManager.fileExists(any())).thenAnswer((invocation) async => false);

        // when
        final result = await downloadAssetsController.assetsFileExists('');

        // then
        expect(result, false);
        verify(() => fileManager.fileExists(any())).called(1);
        verifyNoMoreInteractions(fileManager);
      },
    );
  });

  group('clearAssets', () {
    setUp(
      () async {
        await downloadAssetsController.init(useFullDirectoryPath: true);
      },
    );

    test(
      'Should delete when it was called',
      () async {
        // given
        when(() => fileManager.directoryExists(any())).thenAnswer((invocation) async => true);
        when(() => fileManager.deleteDirectory(any())).thenAnswer((invocation) async => File(''));

        // when
        await downloadAssetsController.clearAssets();

        // then
        verify(() => fileManager.directoryExists((any()))).called(1);
        verify(() => fileManager.deleteDirectory(any())).called(1);
        verifyNoMoreInteractions(fileManager);
      },
    );

    test(
      'Should not delete when it was called',
      () async {
        // given
        when(() => fileManager.directoryExists(any())).thenAnswer((invocation) async => false);

        // when
        await downloadAssetsController.clearAssets();

        // then
        verify(() => fileManager.directoryExists(any())).called(1);
        verifyNever(() => fileManager.deleteDirectory(any()));
        verifyNoMoreInteractions(fileManager);
      },
    );
  });

  group('startDownload', () {
    final assetsUrls = [
      'https://github.com/edjostenes/download_assets/raw/main/download/image_1.png',
      'https://github.com/edjostenes/download_assets/raw/main/download/assets.zip',
      'https://github.com/edjostenes/download_assets/raw/main/download/image_2.png',
      'https://github.com/edjostenes/download_assets/raw/main/download/image_3.png',
    ];

    setUp(
      () async {
        await downloadAssetsController.init(useFullDirectoryPath: true);
      },
    );

    test(
      'Should download all files when it was called',
      () async {
        // given
        when(() => fileManager.createDirectory(any())).thenAnswer((invocation) async => Directory(''));
        when(() => customHttpClient.checkSize(any())).thenAnswer((invocation) async => 0);
        when(
          () => customHttpClient.download(
            any(),
            any(),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            requestExtraHeaders: any(named: 'requestExtraHeaders'),
            requestQueryParams: any(named: 'requestQueryParams'),
          ),
        ).thenAnswer(
          (invocation) async => Response(requestOptions: RequestOptions()),
        );

        // when
        await downloadAssetsController.startDownload(
          uncompressDelegates: [unzipDelegate],
          onCancel: () {},
          assetsUrls: assetsUrls,
          onProgress: (progressValue) {},
          onDone: () {},
        );

        // then
        verify(() => fileManager.createDirectory(any())).called(1);
        verify(() => customHttpClient.checkSize(any())).called(4);
        verify(
          () => customHttpClient.download(
            any(),
            any(),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            requestExtraHeaders: any(named: 'requestExtraHeaders'),
            requestQueryParams: any(named: 'requestQueryParams'),
          ),
        ).called(4);
        verifyNoMoreInteractions(customHttpClient);
        verifyNoMoreInteractions(fileManager);
      },
    );

    test(
      'Should throws a DioException when it was called',
      () async {
        final dioException = DioException(requestOptions: RequestOptions(), type: DioExceptionType.cancel);

        // given
        when(() => fileManager.createDirectory(any())).thenAnswer((invocation) async => Directory(''));
        when(() => customHttpClient.checkSize(any())).thenAnswer((invocation) async => 0);
        when(
          () => customHttpClient.download(
            any(),
            any(),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            requestExtraHeaders: any(named: 'requestExtraHeaders'),
            requestQueryParams: any(named: 'requestQueryParams'),
          ),
        ).thenThrow(dioException);

        // then
        await expectLater(
          () => downloadAssetsController.startDownload(
              uncompressDelegates: [unzipDelegate],
              onCancel: () {},
              assetsUrls: assetsUrls,
              onProgress: (progressValue) {},
              onDone: () {}),
          throwsA(isA<DownloadAssetsException>()),
        );
        verify(() => fileManager.createDirectory(any())).called(1);
        verify(() => customHttpClient.checkSize(any())).called(4);
        verify(
          () => customHttpClient.download(
            any(),
            any(),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            requestExtraHeaders: any(named: 'requestExtraHeaders'),
            requestQueryParams: any(named: 'requestQueryParams'),
          ),
        ).called(1);
        verifyNoMoreInteractions(customHttpClient);
        verifyNoMoreInteractions(fileManager);
      },
    );
  });
}
