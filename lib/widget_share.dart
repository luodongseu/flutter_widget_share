import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

typedef SharePreviewBuilder = Widget Function(
    BuildContext context, File image, VoidCallback onShare);

/// 分享的控制器，用于调用分享功能
///
/// example:
///
/// ```
/// ShareController controller = ShareController();
///
/// controller.share();
/// ```
class ShareController extends ChangeNotifier {
  /// 分享事件
  void share() {
    notifyListeners();
  }
}

/// 可分享的组件
/// 分享使用ShareController控制
///
/// ```
/// ShareWidget(
///   controller: ShareController(),
///   child: Container()
/// )
class ShareWidget extends StatefulWidget {
  /// 任意子控件
  final List<Widget> children;

  /// 分享控制器
  final ShareController controller;

  /// 分享预builder
  final SharePreviewBuilder previewBuilder;

  const ShareWidget({
    @required this.children,
    @required this.controller,
    Key key,
    this.previewBuilder,
  }) : super(key: key);

  @override
  _ShareWidgetState createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    /// 监听share事件
    widget.controller.addListener(() {
      ShareUtils.shareWidget(_key, previewBuilder: widget.previewBuilder,
          onShare: (path) async {
        await ShareExtend.share(path, 'image');
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _key,
      child: Column(children: widget.children),
    );
  }
}

/// 截屏分享
///
/// @author luodongseu&jiayun
class ShareUtils {
  /// 分享一个控件
  ///
  /// @param key: 控件的key
  /// @param title: 分享的标题
  /// @param content: 分享的内容
  static shareWidget(GlobalKey key,
      {title,
      description,
      SharePreviewBuilder previewBuilder,
      ValueChanged<String> onShare}) async {
    assert(key != null, 'key must not be null!');
    assert(key.currentContext.findRenderObject() is RenderRepaintBoundary,
        "RenderRepaintBoundary support only!");

    /// 截图，并且返回图片的缓存地址
    Future<String> _captureWidget2File(File toFile) async {
      // 1. 获取 RenderRepaintBoundary
      RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
      // 2. 生成 Image
      ui.Image image = await boundary.toImage();
      // 3. 生成 Uint8List
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      // 4. 本地存储Image
      toFile.writeAsBytes(pngBytes);
      return toFile.path;
    }

    /// 获取保存的文件
    Future<File> _getSavedImageFile() async {
      Directory tempDir = await getTemporaryDirectory();
      int curT = DateTime.now().millisecondsSinceEpoch;
      String toFilePath = '${tempDir.path}/$curT.png';
      File toFile = File(toFilePath);
      bool exists = await toFile.exists();
      if (!exists) {
        await toFile.create(recursive: true);
      }
      await _captureWidget2File(toFile);
      return toFile;
    }

    File image = await _getSavedImageFile();

    /// 弹框分享
    showDialog(
        context: key.currentContext,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return previewBuilder?.call(context, image, () {
                onShare?.call(image.path);
              }) ??
              Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  height: MediaQuery.of(context).size.height - 200,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                            bottom: 10.0, left: 20.0, top: 10.0),
                        child: Text(
                          '分享截图',
                          style: TextStyle(
                              color: Color(0xFF005960),
                              fontWeight: FontWeight.w700,
                              fontSize: 18),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Image.file(
                            image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 20.0),
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(40.0))),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '取消',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w700),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                onShare?.call(image.path);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 20.0),
                                decoration: BoxDecoration(
                                    color: Color(0xFF005960),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(40.0))),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.share,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                    SizedBox(
                                      width: 6.0,
                                    ),
                                    Text(
                                      '分享',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w700),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
        });
  }
}
