import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);
/*
* @description:
* https://stackoverflow.com/a/64698459/8389461
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/25
*/
main() => runApp(MaterialApp(home: BodyWidget()));

class BodyWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BodyState();
  }
}

class _BodyState extends State<BodyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test_html"),
      ),
      body: IframeDemo(),
    );
  }
}

class IframeDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyWidget();
  }
}

class MyWidget extends State<IframeDemo> {
  late String _url;
  late html.IFrameElement _iframeElement;

  @override
  initState() {
    super.initState();
    _url = 'https://en.wikipedia.org/wiki/Twitter';
    _iframeElement = html.IFrameElement()
      ..src = _url
      ..id = 'iframe'
      ..style.border = 'none';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframeElement',
      (int viewId) => _iframeElement,
    );
  }

  void updateUrl(String page) {
    setState(() {
      // building a new url
      _url = 'https://cn.bing.com/search?q=$page';

      // Setting the url to the src field of the iframe element.
      html.HtmlElement elem = html.document
          .getElementsByTagName('flt-glass-pane')[0] as html.HtmlElement;
      html.HtmlElement fltPlatformView = elem.children.firstWhere(
              (element) => element.tagName.toLowerCase() == "flt-platform-view")
          as html.HtmlElement;

      html.IFrameElement? ifrelem =
          fltPlatformView.firstChild as html.IFrameElement?;
      ifrelem?..src = _url;
      print("elem :${elem}");
      print(
          "fltPlatformView children:${fltPlatformView.children.first.offsetHeight}");
      print(
          "fltPlatformView children:${fltPlatformView.children.first.clientHeight}");
      print(
          "elem flt-platform-view:${elem.getElementsByClassName("flt-platform-view")}");
      print("elem.children :${elem.children.map((e) => e.tagName)}");
      print("elem.shadowRoot :${elem.shadowRoot}");
      print("ifrelem height :${ifrelem?.height}");
      print("ifrelem height :${ifrelem?.scrollHeight}");
      print("ifrelem height :${ifrelem?.clientHeight}");
      print("ifrelem height :${ifrelem?.offsetHeight}");
    });
  }

  @override
  Widget build(BuildContext context) {
    print('url is $_url');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.blueAccent,
              child: Text('Show Twitter wiki'),
              onPressed: () {
                updateUrl('Twitter');
              },
            ),
            SizedBox(
              width: 50,
            ),
            MaterialButton(
              color: Colors.orangeAccent,
              child: Text('Show Facebook Wiki'),
              onPressed: () {
                updateUrl('Facebook');
              },
            ),
          ],
        ),
        SizedBox(
          height: 100,
        ),
        SizedBox(
          height: 600,
          width: 600,
          child: HtmlElementView(
            // key: UniqueKey(),
            viewType: 'iframeElement',
            onPlatformViewCreated: (id) {
              updateUrl("onPlatformViewCreated");
            },
          ),
        ),
      ],
    );
  }
}
