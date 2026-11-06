import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/*
* @description: Added callbacks for webViewController and BuildContext objects to
* the JavaScriptChannel wrapper class of webview_flutter, which is convenient
* for doing some extra operations when H5 calls back the Flutter method
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/25
*/
class WebJavaScriptChannelWrapper {
  String name;
  WebJavascriptMessageHandlerWrapper onMessageReceived;
  WebViewController? webViewController;

  WebJavaScriptChannelWrapper(
      {required this.name, required this.onMessageReceived});

  void registerToController(
      WebViewController controller, BuildContext Function() contextGetter) {
    webViewController = controller;
    controller.addJavaScriptChannel(
      name,
      onMessageReceived: (JavaScriptMessage message) {
        onMessageReceived(message, webViewController, contextGetter());
      },
    );
  }
}

typedef void WebJavascriptMessageHandlerWrapper(JavaScriptMessage message,
    WebViewController? webViewController, BuildContext context);
