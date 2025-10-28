import 'dart:io';

import 'package:download_assets/download_assets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Download Assets Demo',
    theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
    home: const MyHomePage(title: 'Download Assets'),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  DownloadAssetsController downloadAssetsController = DownloadAssetsController();
  String message = 'Press the download button to start the download';
  bool downloaded = false;
  double value = 0.0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    await downloadAssetsController.init();
    downloaded = await downloadAssetsController.assetsDirAlreadyExists();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (downloaded) ...[
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File('${downloadAssetsController.assetsDir}/image_3.jpeg')),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File('${downloadAssetsController.assetsDir}/image_1.png')),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            tween: Tween<double>(begin: 0, end: value),
            builder: (context, value, _) => LinearProgressIndicator(minHeight: 10, value: value),
          ),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
    floatingActionButton: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FloatingActionButton(onPressed: _downloadAssets, tooltip: 'Download', child: const Icon(Icons.arrow_downward)),
        const SizedBox(width: 25),
        FloatingActionButton(
          onPressed: () async {
            await downloadAssetsController.clearAssets();
            await _downloadAssets();
          },
          tooltip: 'Refresh',
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 25),
        FloatingActionButton(onPressed: _cancel, tooltip: 'Cancel', child: const Icon(Icons.cancel_outlined)),
      ],
    ), // This trailing comma makes auto-formatting nicer for build methods.
  );

  Future _downloadAssets() async {
    final assetsDownloaded = await downloadAssetsController.assetsDirAlreadyExists();

    if (assetsDownloaded) {
      setState(() {
        message = 'Click in refresh button to force download';
      });
      return;
    }

    try {
      value = 0.0;
      downloaded = false;
      await downloadAssetsController.startDownload(
        onCancel: () {
          message = 'Cancelled by user';
          setState(() {});
        },
        assetsUrls: const [
          AssetUrl(url: 'https://github.com/edjostenes/download_assets/raw/main/download/image_1.png'),
          AssetUrl(url: 'https://github.com/edjostenes/download_assets/raw/main/download/assets.zip'),
          AssetUrl(url: 'https://github.com/edjostenes/download_assets/raw/main/download/image_2.png'),
          AssetUrl(url: 'https://github.com/edjostenes/download_assets/raw/main/download/image_3.png'),
        ],
        onProgress: (progressValue) {
          value = progressValue;
          setState(() {
            message = 'Downloading - ${(progressValue * 100).toStringAsFixed(2)}';
          });
        },
        onDone: () {
          setState(() {
            downloaded = true;
            message = 'Download completed\nClick in refresh button to force download';
          });
        },
      );
    } on DownloadAssetsException catch (e) {
      setState(() {
        downloaded = false;
        message = 'Error: ${e.toString()}';
      });
    }
  }

  void _cancel() => downloadAssetsController.cancelDownload();
}
