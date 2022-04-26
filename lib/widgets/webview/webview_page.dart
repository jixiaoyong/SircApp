import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';
import 'package:sirc/utils/logger.dart';
import 'package:sirc/widgets/webview/web_java_script_channel.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../endless_rotating_indicator.dart';
import '../gradient_progress_indicator.dart';

/*
* @description: 将webview_flutter封装为单独的页面
* 做了如下修改：
* 1. 增加顶部进度条
* 2. 展示标题(优先使用传入的title)
* 3. 自动根据是否传入javascriptChannels启用或禁用js调用
*
* 使用时只需要跳转到本页面，并传递网址等信息即可：
* Navigator.of(context).push(MaterialPageRoute(
*                   builder: (context) => WebViewPage("https://baidu.com")));
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/25
*/
class WebViewPage extends StatefulWidget {
  String? title;
  String? url;
  Set<WebJavaScriptChannelWrapper>? javascriptChannels;
  bool needAppBar;

  // 是否使用SurfaceAndroidWebView，以兼容Android 12 输入法等情况
  bool needSurfaceAndroidWebView;

  WebViewPage(
    this.url, {
    this.title,
    this.javascriptChannels,
    this.needAppBar = true,
    this.needSurfaceAndroidWebView = false,
  }) {
    LogUtils.d("WebViewPage open url: $url");
  }

  @override
  State<StatefulWidget> createState() {
    return WebViewPageState();
  }
}

class WebViewPageState extends State<WebViewPage> {
  int progress = 0;
  WebViewController? _viewController;
  Set<JavascriptChannel>? _innerJsChannels = {};
  var cachedWebViewPlatform = WebView.platform;

  @override
  void initState() {
    super.initState();
    // 华为手机不要切换webview到SurfaceAndroidWebView，会导致闪屏
    if (Platform.isAndroid && widget.needSurfaceAndroidWebView) {
      WebView.platform = SurfaceAndroidWebView();
      LogUtils.d("switch webview to ${WebView.platform}");
    }
    LogUtils.d("current webview is ${WebView.platform}");
  }

  @override
  void dispose() {
    if (Platform.isAndroid) WebView.platform = cachedWebViewPlatform;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var realJavascriptChannels = widget.javascriptChannels
        ?.map((e) => e.getRealMessageChannel(context))
        .toSet();
    _innerJsChannels = realJavascriptChannels;
    var bodyWidget;
    if (widget.needAppBar) {
      bodyWidget = Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title ?? "",
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          brightness: Brightness.light,
          elevation: 0.5,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.black,
              )),
          backgroundColor: Colors.white,
        ),
        body: buildWebViewContent(),
      );
    } else {
      SystemUiOverlayStyle uiStyle = SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      );
      SystemChrome.setSystemUIOverlayStyle(uiStyle);
      bodyWidget = buildWebViewContent();
    }

    return WillPopScope(
        child: bodyWidget,
        onWillPop: () async {
          var canGoBack = await _viewController?.canGoBack() ?? false;
          if (canGoBack) {
            _viewController?.goBack();
            return false;
          }
          return true;
        });
  }

  Stack buildWebViewContent() {
    return Stack(
      children: [
        WebView(
          initialUrl: widget.url,
          javascriptMode: widget.javascriptChannels?.isNotEmpty == true
              ? JavascriptMode.unrestricted
              : JavascriptMode.disabled,
          onWebViewCreated: (webViewController) async {
            _viewController = webViewController;
            widget.javascriptChannels?.forEach((element) {
              if (element is WebJavaScriptChannelWrapper) {
                element.webViewController = _viewController;
                return;
              }
            });
          },
          onProgress: (_progress) {
            setState(() {
              progress = _progress;
            });
          },
          onPageFinished: (url) {
            if (true != widget.title?.isNotEmpty) {
              _viewController?.getTitle().then((value) {
                setState(() {
                  widget.title = value;
                });
              });
            }
          },
          gestureNavigationEnabled: true,
          javascriptChannels: _innerJsChannels,
        ),
        Visibility(
          visible: progress < 100,
          child: Column(
            children: [
              GradientProgressIndicator(
                progress: progress / 100.0,
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        child: const EndlessRotatingIndicator(
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ))
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
