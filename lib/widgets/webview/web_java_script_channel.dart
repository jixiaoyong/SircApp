import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/*
* @description: Added callbacks for webViewController and BuildContext objects to
* the JavascriptChannel wrapper class of webview_flutter, which is convenient
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
      {required this.name, required this.onMessageReceived}) {}

  JavascriptChannel getRealMessageChannel(BuildContext context) {
    return JavascriptChannel(
        name: name,
        onMessageReceived: (JavascriptMessage message) {
          onMessageReceived(message, webViewController, context);
        });
  }
}

typedef void WebJavascriptMessageHandlerWrapper(JavascriptMessage message,
    WebViewController? webViewController, BuildContext context);
