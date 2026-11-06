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

  // 是否使用SurfaceAndroidWebView，以兼容Android 12 输入法等情况（4.x已内置适配，保留字段兼容）
  bool needSurfaceAndroidWebView;

  WebViewPage(
    this.url, {
    Key? key,
    this.title,
    this.javascriptChannels,
    this.needAppBar = true,
    this.needSurfaceAndroidWebView = false,
  }) : super(key: key) {
    LogUtils.d("WebViewPage open url: $url");
  }

  @override
  State<StatefulWidget> createState() {
    return WebViewPageState();
  }
}

class WebViewPageState extends State<WebViewPage> {
  int progress = 0;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(
        widget.javascriptChannels?.isNotEmpty == true
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progressValue) {
            if (mounted) {
              setState(() {
                progress = progressValue;
              });
            }
          },
          onPageFinished: (String url) async {
            if (widget.title == null || widget.title!.isEmpty) {
              final pageTitle = await _controller.getTitle();
              if (mounted && pageTitle != null && pageTitle.isNotEmpty) {
                setState(() {
                  widget.title = pageTitle;
                });
              }
            }
          },
        ),
      );

    if (widget.javascriptChannels != null) {
      for (final channel in widget.javascriptChannels!) {
        channel.registerToController(_controller, () => context);
      }
    }

    if (widget.url != null && widget.url!.isNotEmpty) {
      _controller.loadRequest(Uri.parse(widget.url!));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;
    if (widget.needAppBar) {
      bodyWidget = Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title ?? "",
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          elevation: 0.5,
          leading: IconButton(
              onPressed: () async {
                final bool canGoBack = await _controller.canGoBack();
                if (canGoBack) {
                  await _controller.goBack();
                } else {
                  Get.back();
                }
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final bool canGoBack = await _controller.canGoBack();
        if (canGoBack) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop(result);
          }
        }
      },
      child: bodyWidget,
    );
  }

  Stack buildWebViewContent() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
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
                  children: const [
                    EndlessRotatingIndicator(
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    )
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
