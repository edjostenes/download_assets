import 'dart:io';

import 'package:download_assets/download_assets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Download Assets Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Download Assets'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? title;

  MyHomePage({Key? key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String message = "Press the download button to start the download";
  bool downloaded = false;

  @override
  void initState() {
    super.initState();
    DownloadAssetsController.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ""),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(message),
            if (downloaded)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File("${DownloadAssetsController.assetsDir}/dart.jpeg")),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            if (downloaded)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File("${DownloadAssetsController.assetsDir}/flutter.png")),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _downloadAssets,
            tooltip: 'Increment',
            child: Icon(Icons.arrow_downward),
          ),
          SizedBox(width: 25,),
          FloatingActionButton(
            onPressed: _refresh,
            tooltip: 'Refresh',
            child: Icon(Icons.refresh),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future _refresh() async {
    await DownloadAssetsController.clearAssets();
    await _downloadAssets();
  }

  Future _downloadAssets() async {
    bool assetsDownloaded = await DownloadAssetsController.assetsDirAlreadyExists();

    if (assetsDownloaded) {
      setState(() {
        message = "Click in refresh button to force download";
        print(message);
      });
      return;
    }

    try {
      await DownloadAssetsController.startDownload(
          assetsUrl: "https://github.com/edjostenes/download_assets/raw/master/assets.zip",
          onProgress: (progressValue) {
            downloaded = false;
            setState(() {
              message = "Downloading - ${progressValue.toStringAsFixed(2)}";
              print(message);
            });
          },
          onComplete: () {
            setState(() {
              message = "Download compeleted\nClick in refresh button to force download";
              downloaded = true;
            });
          },
          onError: (exception) {
            setState(() {
              downloaded = false;
              message = "Error: ${exception.toString()}";
            });
          }
      );
    } on DownloadAssetsException catch (e) {
      print(e.toString());
    }
  }
}
