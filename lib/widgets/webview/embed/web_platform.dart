import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sirc/data/common_date.dart';
import 'package:sirc/utils/logger.dart';

/*
* @description:
* https://stackoverflow.com/a/60089273/8389461
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/25
*/
class WebView4WebPlatform extends StatefulWidget {
  final double width;
  final String webContent;

  WebView4WebPlatform(this.width, this.webContent);

  _WebView4WebPlatformState createState() => _WebView4WebPlatformState();
}

class _WebView4WebPlatformState extends State<WebView4WebPlatform> {
  String createdViewId = 'map_element';

  late html.IFrameElement element;

  @override
  void initState() {
    if (kIsWeb) {
      element = html.IFrameElement()
        ..id = 'iframe'
        ..width = widget.width.toString()
        ..style.width = widget.width.toString()
        ..style.height = 'auto'
        // ..offsetWidth = widget.width.toInt()
        ..height = "auto"
        // ..innerHtml = widget.webContent
        ..srcdoc = widget.webContent
        ..style.border = 'none';

      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(createdViewId, (int viewId) {
        return element;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double height = 10;
  double width = 10;

  @override
  Widget build(BuildContext context) {
    // var _width = widget.width * MediaQuery.of(context).devicePixelRatio;

    LogUtils.d(
        "    final _width = MediaQuery.of(context).size.width:${MediaQuery.of(context).size.width}");
    return SizedBox(
        width: width,
        height: height,
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: HtmlElementView(
              viewType: createdViewId,
              onPlatformViewCreated: (int viewId) {
                print('viewId: $viewId');
                html.HtmlElement elem =
                    html.document.getElementsByTagName('flt-glass-pane')[0]
                        as html.HtmlElement;
                html.HtmlElement fltPlatformView = elem.children.firstWhere(
                    (element) =>
                        element.tagName.toLowerCase() ==
                        "flt-platform-view") as html.HtmlElement;

                html.IFrameElement? ifrelem =
                    fltPlatformView.firstChild as html.IFrameElement?;
                LogUtils.d(
                    "fltPlatformView children:${fltPlatformView.children.first.offsetHeight}");
                LogUtils.d(
                    "fltPlatformView children:${fltPlatformView.children.first.clientHeight}");

                LogUtils.d(
                    " html.document offsetHeight ${html.document.documentElement?.offsetHeight}");
                LogUtils.d(
                    " html.document scrollHeight ${html.document.documentElement?.scrollHeight}");
                LogUtils.d(
                    " html.document clientHeight ${html.document.documentElement?.clientHeight}");
                LogUtils.d(
                    " html.document offsetWidth ${html.document.documentElement?.offsetWidth}");
                LogUtils.d(
                    " html.document clientWidth ${html.document.documentElement?.clientWidth}");
                LogUtils.d(
                    " html.document scrollWidth ${html.document.documentElement?.scrollWidth}");

                LogUtils.d("element height :${ifrelem?.height}");
                LogUtils.d(
                    "element offsetHeight :${ifrelem?.ownerDocument?.documentElement?.offsetHeight}");
                LogUtils.d(
                    "element offsetHeight :${ifrelem?.ownerDocument?.documentElement?.clientHeight}");
                LogUtils.d(
                    "element offsetHeight 3:${ifrelem?.ownerDocument?.documentElement?.ownerDocument?.documentElement?.clientHeight}");
                LogUtils.d("element clientHeight :${ifrelem?.clientHeight}");
                LogUtils.d("element scrollHeight :${ifrelem?.contentWindow}");

                LogUtils.d(
                    "MediaQuery.of(context).devicePixelRatio ${MediaQuery.of(context).devicePixelRatio}");
                setState(() {
                  var _screenWidth = MediaQuery.of(context).size.width;
                  var ratio = _screenWidth / CommonData.realScreenWidth;
                  // height =
                  //     (html.document.documentElement?.clientWidth.toDouble() ??
                  //             0.0) /
                  //         ratio;
                  height =
                      fltPlatformView.children.first.offsetHeight.toDouble();
                  width =
                      (html.document.documentElement?.clientWidth.toDouble() ??
                              0.0) /
                          ratio;
                });
              },
            )));
  }
}
