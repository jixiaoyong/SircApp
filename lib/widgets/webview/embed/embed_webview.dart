import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sirc/utils/logger.dart';
import 'package:sirc/widgets/webview/embed/web_platform.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'webview_utils.dart';

/*
* @description: 能够嵌套在页面内部的WebView
*
* 使用：
* var screenWidth = MediaQuery.of(context).size.width - 50;
* EmbedWebView(webViewContent, screenWidth),
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 2021/11/30
*/
class EmbedWebView extends StatefulWidget {
  String webViewContent = "";
  double width = 0;
  double? maxHeight = 0;
  String? fontSize;
  String? backgroundColor;
  String? lineHeight;
  bool forceExpandImageWidget;

  /// 能够嵌套在页面内部的WebView
  /// @param [webViewContent]: 页面内容，
  ///   页面间传递中文需要用Uri.encodeComponent转换，
  ///   否则就报Invalid argument(s): Illegal percent encoding in URI异常
  /// @param [width]: 控件的宽度，决定了图片最大宽度
  /// @param [maxHeight] 最大高度，超出则滑动WebView,没有则不限制高度
  /// @param [fontSize]: 网页文本的字体大小，如"4vw"(计算方式见[WebViewUtils.font_size])，不指定则用默认的大小
  /// @param [backgroundColor] 网页的背景颜色，格式为#RRGGBB，默认白色
  /// @param [lineHeight] 网页的字体行高，单位em，默认1.8em
  /// @param [forceExpandImageWidget]: force expand image widget's width and height to fit the screen
  EmbedWebView(this.webViewContent, this.width,
      {this.maxHeight,
      this.fontSize,
      this.backgroundColor,
      this.lineHeight,
      this.forceExpandImageWidget = false}) {
    if (webViewContent.isNotEmpty) {
      webViewContent = Uri.encodeComponent(webViewContent);
    }
  }

  @override
  State<EmbedWebView> createState() => _EmbedWebViewState();
}

class _EmbedWebViewState extends State<EmbedWebView> {
  double _heights = 10;
  double _screenMaxHeightPx = double.infinity;

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
  void dispose() {
    super.dispose();
    if (!kIsWeb && cachePlatform != null) {
      WebView.platform = cachePlatform;
    }
  }

  @override
  Widget build(BuildContext context) {
    var widthPx = widget.width * MediaQuery.of(context).devicePixelRatio;
    var maxHeight = widget.maxHeight;
    _screenMaxHeightPx = maxHeight == null
        ? _screenMaxHeightPx
        : maxHeight * MediaQuery.of(context).devicePixelRatio;
    var webViewContentHtml = WebViewUtils.getWebContent(
        widget.webViewContent, widthPx.toInt(),
        fontSize: widget.fontSize,
        backgroundColor: widget.backgroundColor,
        forceExpandImageWidget: widget.forceExpandImageWidget,
        lineHeight: widget.lineHeight);

    LogUtils.d("build webViewContentHtml:$webViewContentHtml");
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: _screenMaxHeightPx),
      child: SingleChildScrollView(
        child: GestureDetector(
          onHorizontalDragUpdate: (value) {},
          child: kIsWeb
              ? SizedBox(
                  width: widget.width,
                  child: WebView4WebPlatform(
                      widget.width * MediaQuery.of(context).devicePixelRatio,
                      webViewContentHtml),
                )
              : SizedBox(
                  width: widget.width,
                  height: _heights,
                  child: _buildWebView(webViewContentHtml),
                ),
        ),
      ),
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
    var widthPx = widget.width * MediaQuery.of(context).devicePixelRatio;

    var webWidgetScale = webViewWidth / widthPx;

    double height = double.parse(await webViewController?.evaluateJavascript(
                "document.getElementById('webContent').clientHeight") ??
            "0.0") *
        devicePixelRatio;

    height = (height / webWidgetScale) + 1;

    if (height == _heights) {
      return;
    }
    setState(() {
      LogUtils.d("WebView height:$height");
      _heights = height / MediaQuery.of(context).devicePixelRatio;
    });
  }
}
