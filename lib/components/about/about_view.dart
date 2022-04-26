import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/gen_a/A.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';
import 'package:sirc/widgets/webview/embed/embed_webview.dart';

import 'about_logic.dart';

/*
* @description: AboutPage
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/25
*/
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Get.put(AboutLogic());

    final _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: "About".tr,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.dp),
            child: Center(
              child: Image.asset(
                A.assets_ic_launcher,
                width: 100.dp,
                height: 100.dp,
              ),
            ),
          ),
          EmbedWebView(
            logic.aboutText,
            _width,
            backgroundColor: "#fafafa",
          ),
          Container(
            width: 200,
            height: 200.dp,
            color: Colors.blue,
            child: const Center(child: Text("To be continued...",style: TextStyle(color: Colors.white),)),
          ),
        ],
      ),
    );
  }
}
