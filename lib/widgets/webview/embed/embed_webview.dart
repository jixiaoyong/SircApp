import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sirc/utils/logger.dart';

import 'embed_webview_stub.dart';
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
  // double _heights = 10;
  double _screenMaxHeightPx = double.infinity;

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
            child: SizedBox(
              width: widget.width,
              child: getEmbedWebViewAuto(
                webViewContentHtml,
                widget.width * MediaQuery.of(context).devicePixelRatio,
              ),
            )),
      ),
    );
  }
}
