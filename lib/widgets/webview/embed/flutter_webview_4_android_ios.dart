import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../utils/logger.dart';

Widget getEmbedWebView(String srcDoc, [double? width, double? height]) =>
    FlutterWebview4AndroidIos(
      webViewContent: srcDoc,
      width: width ?? 0,
    );

class FlutterWebview4AndroidIos extends StatefulWidget {
  String webViewContent;

  // widget width, unit is px
  double width = 0;
  double? maxHeight = 0;

  FlutterWebview4AndroidIos(
      {Key? key,
      required this.webViewContent,
      this.width = 0,
      this.maxHeight = 0})
      : super(key: key);

  @override
  State<FlutterWebview4AndroidIos> createState() =>
      _FlutterWebview4AndroidIosState();
}

class _FlutterWebview4AndroidIosState extends State<FlutterWebview4AndroidIos> {
  double _heights = 10;
  double? _widgetWidth;

  WebViewController? webViewController;
  WebViewPlatform? cachePlatform;
  WebView? _webView;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isAndroid) {
      cachePlatform = WebView.platform;
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    _widgetWidth = widget.width / MediaQuery.of(context).devicePixelRatio;
    return SizedBox(
      width: _widgetWidth,
      height: _heights,
      child: _buildWebView(widget.webViewContent),
    );
  }

  WebView _buildWebView(String webViewContentHtml) {
    if (_webView == null) {
      LogUtils.d("_webView == null");
      _webView = WebView(
        onWebViewCreated: (WebViewController webViewController) async {
          this.webViewController = webViewController;
          await _refreshWebViewContent(webViewController, webViewContentHtml);
        },
        onPageFinished: (some) async {
          LogUtils.d("WebView height:onPageFinished");
          await _onPageFinished();
        },
        javascriptMode: JavascriptMode.unrestricted,
      );
    } else {
      LogUtils.d("_webView != null");
      webViewController?.currentUrl().then((value) {
        var newUrl = Uri.dataFromString(webViewContentHtml,
                mimeType: 'text/html', encoding: Encoding.getByName("utf-8"))
            .toString();

        if (newUrl != value) {
          _refreshWebViewContent(webViewController!, webViewContentHtml);
        }
      });
    }
    return _webView!;
  }

  Future<void> _refreshWebViewContent(
      WebViewController webViewController, String webViewContentHtml) async {
    await webViewController.loadUrl(Uri.dataFromString(webViewContentHtml,
            mimeType: 'text/html', encoding: Encoding.getByName("utf-8"))
        .toString());
  }

  Future<void> _onPageFinished() async {
    double devicePixelRatio = double.parse(await webViewController
            ?.evaluateJavascript("window.devicePixelRatio") ??
        "0.0");

    double webViewWidth = double.parse(await webViewController
                ?.evaluateJavascript("document.body.scrollWidth") ??
            "0.0") *
        devicePixelRatio;
    var widthPx = widget.width;

    var webWidgetScale = webViewWidth / widthPx;

    double height = double.parse(await webViewController?.evaluateJavascript(
                "document.getElementById('webContent').scrollHeight") ??
            "0.0") *
        devicePixelRatio;

    height = (height / webWidgetScale) + 1;

    if (height == _heights) {
      return;
    }
    setState(() {
      LogUtils.d("WebView height:$height");
      _heights = height / MediaQuery.of(context).devicePixelRatio;
      LogUtils.d("WebView widget height:$_heights");
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (!kIsWeb && cachePlatform != null) {
      WebView.platform = cachePlatform;
    }
  }
}
