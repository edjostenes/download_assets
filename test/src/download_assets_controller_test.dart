import 'dart:io';

import 'package:download_assets/download_assets.dart';
import 'package:download_assets/src/download_assets_controller_impl.dart';
import 'package:download_assets/src/managers/file/file_manager.dart';
import 'package:download_assets/src/managers/http/custom_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFileManager extends Mock implements FileManager {}

class MockCustomHttpClient extends Mock implements CustomHttpClient {}

void main() {
  late FileManager fileManager;
  late CustomHttpClient customHttpClient;
  late DownloadAssetsController downloadAssetsController;

  setUp(() {
    fileManager = MockFileManager();
    customHttpClient = MockCustomHttpClient();
    downloadAssetsController = DownloadAssetsControllerImpl(
      fileManager: fileManager,
      customHttpClient: customHttpClient,
    );
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
}
