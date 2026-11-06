import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../utils/logger.dart';

Widget getEmbedWebView(String srcDoc, [double? width, double? height]) =>
    FlutterWebview4AndroidIos(
      webViewContent: srcDoc,
      width: width ?? 0,
    );

class FlutterWebview4AndroidIos extends StatefulWidget {
  final String webViewContent;

  // widget width, unit is px
  final double width;
  final double? maxHeight;

  const FlutterWebview4AndroidIos(
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

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            LogUtils.d("WebView height:onPageFinished");
            await _onPageFinished();
          },
        ),
      );
    _refreshWebViewContent(widget.webViewContent);
  }

  @override
  void didUpdateWidget(covariant FlutterWebview4AndroidIos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.webViewContent != widget.webViewContent) {
      _refreshWebViewContent(widget.webViewContent);
    }
  }

  Future<void> _refreshWebViewContent(String webViewContentHtml) async {
    await _controller.loadRequest(
      Uri.dataFromString(
        webViewContentHtml,
        mimeType: 'text/html',
        encoding: Encoding.getByName("utf-8"),
      ),
    );
  }

  Future<double> _evaluateDouble(String javascript) async {
    try {
      final result = await _controller.runJavaScriptReturningResult(javascript);
      if (result is num) {
        return result.toDouble();
      }
      final str = result.toString().replaceAll('"', '').trim();
      return double.tryParse(str) ?? 0.0;
    } catch (e) {
      LogUtils.e("runJavaScriptReturningResult error: $e");
      return 0.0;
    }
  }

  Future<void> _onPageFinished() async {
    double devicePixelRatio =
        await _evaluateDouble("window.devicePixelRatio");
    if (devicePixelRatio == 0.0) {
      devicePixelRatio = 1.0;
    }

    double scrollWidth =
        await _evaluateDouble("document.body.scrollWidth");
    double webViewWidth = scrollWidth * devicePixelRatio;
    var widthPx = widget.width;

    var webWidgetScale = widthPx > 0 ? (webViewWidth / widthPx) : 1.0;

    double scrollHeight = await _evaluateDouble(
        "document.getElementById('webContent').scrollHeight");
    double height = scrollHeight * devicePixelRatio;

    height = (height / webWidgetScale) + 1;

    if (!mounted || height == _heights) {
      return;
    }
    setState(() {
      LogUtils.d("WebView height:$height");
      _heights = height / MediaQuery.of(context).devicePixelRatio;
      LogUtils.d("WebView widget height:$_heights");
    });
  }

  @override
  Widget build(BuildContext context) {
    _widgetWidth = widget.width / MediaQuery.of(context).devicePixelRatio;
    return SizedBox(
      width: _widgetWidth,
      height: _heights,
      child: WebViewWidget(controller: _controller),
    );
  }
}
