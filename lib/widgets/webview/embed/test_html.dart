import 'dart:html' as html;
import 'dart:html';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  double _iframeElementHeight = 100;
  String iframeId = "MyIframeId";

  String scrdoc =
      """<p style="text-align: center;"><span style="font-size: 19px;"><strong>Sirc&nbsp;</strong></span><img src="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" alt="" data-href="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" width='400px' style=""></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">an&nbsp;open-source&nbsp;Flutter&nbsp;financial&nbsp;application.</span></p><p style="text-align: center;"><span style="color: rgb(41, 44, 50); font-size: 19px;">Made&nbsp;With&nbsp;❤️&nbsp;by&nbsp;JI,XIAOYONG.</span></p><p><br></p>""";

  String ss = """<!DOCTYPE html>
<html>
  
  <head>
    <meta charset="utf-8">
    <title></title>

  </head>
  
  <body>
    <p style="text-align: center;">
      <span style="font-size: 19px;">
        <strong>Sirc&nbsp;</strong></span>
      <img src="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" alt="" data-href="https://github.com/jixiaoyong/SircApp/actions/workflows/main.yml/badge.svg" width='400px' style=""></p>
    <p style="text-align: center;">
      <br></p>
    <p style="text-align: center;">
      <span style="color: rgb(41, 44, 50); font-size: 19px;">an&nbsp;open-source&nbsp;Flutter&nbsp;financial&nbsp;application.</span></p>
    <p style="text-align: center;">
      <span style="color: rgb(41, 44, 50); font-size: 19px;">Made&nbsp;With&nbsp;❤️&nbsp;by&nbsp;JI,XIAOYONG.</span></p>
    <p>
      <br></p>

                 <script>
                //  import 'dart:js';
                var bodyEle = document.body;
                console.log(bodyEle);

                console.log(bodyEle.scrollHeight)
                // updateHeight(bodyEle.scrollHeight);
                //  nativeBridge.postMessage(args)

                //----1---//
function connectDevice() {
ConnectBLE.postMessage('ble.connect');
}
//----2---//
function getDocumentHeight(){
console.log('*** Update Device Status ***');
return bodyEle.scrollHeight;
}
            
            </script>
  </body>

</html>""";

  @override
  initState() {
    super.initState();
    // _url = 'https://xiaoyong.ml/';
    // _url = 'https://xiaoyong.ml/blog/';

    _iframeElement = html.IFrameElement()
      ..srcdoc = ss
      // ..src = _url
      ..id = iframeId
      ..onLoad.listen((event) async {
        var body = querySelector("#MyIframeId");
        // https://stackoverflow.com/a/28278469/8389461
        var jsIFrame = js.JsObject.fromBrowserObject(body as Object);
        var contentHeight =
            // jsIFrame["contentDocument"]["body"]["scrollHeight"];
            jsIFrame["contentDocument"]["documentElement"]["scrollHeight"];
            // jsIFrame["#document"];

        print("contentHeight:  $contentHeight");
        setState(() {
          _iframeElementHeight = contentHeight.toDouble();
        });
      })
      ..height = "auto"
      ..style.border = 'none';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframeElement',
      (int viewId) => _iframeElement,
    );
    // _afterRender();
  }

  void updateHeight(double height) {
    print("js call $height");
    setState(() {
      _iframeElementHeight = height;
    });
  }

  void _afterRender() {
    print("afterRender");
    html.HtmlElement elem = html.document
        .getElementsByTagName('flt-glass-pane')[0] as html.HtmlElement;
    html.HtmlElement fltPlatformView = elem.children.firstWhere(
            (element) => element.tagName.toLowerCase() == "flt-platform-view")
        as html.HtmlElement;

    html.IFrameElement iframe = fltPlatformView.children.firstWhere((element) {
      return element.id == iframeId;
    }) as html.IFrameElement;
    print("iframe  ${iframe.id}");
    print("iframe  ${iframe.tagName}");
    iframe.height = "auto";
   
  }

  void updateUrl(String page) {
    setState(() {
      // building a new url
      // _url = 'https://cn.bing.com/search?q=$page';
      // _url = 'https://xiaoyong.ml/blog/posts/e15dda2e/';

      // Setting the url to the src field of the iframe element.
      html.HtmlElement elem = html.document
          .getElementsByTagName('flt-glass-pane')[0] as html.HtmlElement;
      html.HtmlElement fltPlatformView = elem.children.firstWhere(
              (element) => element.tagName.toLowerCase() == "flt-platform-view")
          as html.HtmlElement;

      html.IFrameElement? ifrelem =
          fltPlatformView.firstChild as html.IFrameElement?;
      ifrelem?..src = _url;

    });
  }

  @override
  Widget build(BuildContext context) {


    return SingleChildScrollView(
      child: Column(
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
            height: _iframeElementHeight,
            width: 600,
            child: HtmlElementView(
              // key: UniqueKey(),
              viewType: 'iframeElement',
              onPlatformViewCreated: (id) {
                // updateUrl("onPlatformViewCreated");
                // _afterRender();
              },
            ),
          ),
          Container(
            height: 100,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

}
