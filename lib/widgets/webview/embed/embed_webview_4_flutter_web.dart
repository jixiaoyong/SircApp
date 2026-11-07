// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Widget getEmbedWebView(String srcDoc, [double? width, double? height]) =>
    EmbedWebView4FlutterWeb(
      srcDoc: srcDoc,
      width: width,
      height: height,
    );

///
/// @author: jixiaoyong
/// @email: jixiaoyong1995@gmail.com
/// @date: 22/04/25
/// @description:
/// A widget that displays a WebView in Flutter Web.
class EmbedWebView4FlutterWeb extends StatefulWidget {
  final String srcDoc;
  final double? width;
  final double? height;

  const EmbedWebView4FlutterWeb(
      {super.key, required this.srcDoc, this.width, this.height});

  @override
  State<StatefulWidget> createState() {
    if (!kIsWeb) {
      throw Exception("EmbedWebView4FlutterWeb is only supported in web.");
    }
    return EmbedWebView4FlutterWebState();
  }
}

class EmbedWebView4FlutterWebState extends State<EmbedWebView4FlutterWeb> {
  late html.IFrameElement _iframeElement;
  late double _iframeElementHeight;
  late double _iframeElementWidth;
  String iframeId = "MyIframeId";

  @override
  void initState() {
    super.initState();

    _iframeElementHeight = widget.height ?? 160.0;
    _iframeElementWidth = widget.width ?? 320.0;
    iframeId = "$iframeId${DateTime.now().millisecondsSinceEpoch}";

    _iframeElement = html.IFrameElement()
      ..srcdoc = widget.srcDoc
      ..id = iframeId
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.pointerEvents = 'none'
      ..onLoad.listen((event) async {
        try {
          final body = html.querySelector("#$iframeId") ?? _iframeElement;
          final jsIFrame = js.JsObject.fromBrowserObject(body);
          final documentElement = jsIFrame["contentDocument"]?["documentElement"];
          if (documentElement != null) {
            final h = documentElement["scrollHeight"]?.toDouble();
            final w = documentElement["scrollWidth"]?.toDouble();
            if (h != null && h > 20 && mounted) {
              setState(() {
                _iframeElementHeight = h;
                if (w != null && w > 20) _iframeElementWidth = w;
              });
            }
          }
        } catch (e) {
          debugPrint("iframe height detect: $e");
        }
      });

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      iframeId,
      (int viewId) => _iframeElement,
    );
  }

  void updateHeight(double height) {
    if (mounted) {
      setState(() {
        _iframeElementHeight = height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? (_iframeElementHeight > 20 ? _iframeElementHeight : 160.0),
      width: widget.width ?? (_iframeElementWidth > 20 ? _iframeElementWidth : double.infinity),
      child: HtmlElementView(
        viewType: iframeId,
      ),
    );
  }
}
