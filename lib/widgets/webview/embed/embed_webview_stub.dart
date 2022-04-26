import 'package:flutter/widgets.dart';

import 'web_view_proxy.dart'
    if (dart.library.js) 'embed_webview_4_flutter_web.dart'
    if (dart.library.io) 'flutter_webview_4_android_ios.dart';

/// conditional import
/// Only in this way, we can use android/ios and flutter web library in the same project.
/// inspired by https://github.com/Zeruel92/cross_picker
/// https://medium.com/flutter-community/conditional-imports-across-flutter-and-web-4b88885a886e
Widget getEmbedWebViewAuto(String srcDoc, [double? width, double? height]) {
  return getEmbedWebView(srcDoc, width, height);
}
