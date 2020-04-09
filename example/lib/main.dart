import 'package:flutter/material.dart';
import 'package:widget_share/widget_share.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ShareController shareController = new ShareController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ShareWdiget example app'),
          actions: <Widget>[
            InkWell(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(Icons.share),
              ),
              onTap: () {
                shareController.share();
              },
            )
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: ShareWidget(
              controller: shareController,
//              previewBuilder: (c, image, onShare) {
//                return new Dialog(
//                  child: Column(
//                    children: <Widget>[
//                      Expanded(
//                        child: SingleChildScrollView(
//                          child: Image.file(
//                            image,
////                        width: 200,
////                    height: 300,
//                          ),
//                        ),
//                      ),
//                      FlatButton(onPressed: onShare, child: Text('点我点我'))
//                    ],
//                  ),
//                );
//              },
              children: <Widget>[
                Image.asset('assets/example1.jpg'),
                Image.network(
                  'https://user-gold-cdn.xitu.io/2019/6/16/16b5c032c5848f8b?imageslim',
                  width: 200,
                  height: 800,
                ),
                Text('我是文字。。。。'),
                Image.network(
                  'https://user-gold-cdn.xitu.io/2019/6/16/16b5c032c5848f8b?imageslim',
                  width: 200,
                  height: 800,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
