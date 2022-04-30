import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/gen_a/A.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/one_title_with_back_button_appbar.dart';
import 'package:sirc/widgets/webview/embed/embed_webview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      body: Padding(
        padding: EdgeInsets.all(15.dp),
        child: Column(
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
            Padding(
              padding: EdgeInsets.only(bottom: 20.dp),
              child: RichText(
                  text: TextSpan(
                children: [
                  TextSpan(
                      text: "This is an open source project,which host on ".tr,
                      children: [
                        TextSpan(
                            text: "Github.com/jixiaoyong/SircApp",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => openUrl(
                                  "https://github.com/jixiaoyong/SircApp"),
                            style: const TextStyle(color: Colors.blue))
                      ]),
                  const TextSpan(
                    text:
                        ", support android/iOS/Web platform.\nYou may want try the online version:",
                  ),
                  TextSpan(
                      text: "xiaoyong.ml/SircApp/",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => openUrl("https://xiaoyong.ml/SircApp/"),
                      style: const TextStyle(color: Colors.blue)),
                  const TextSpan(
                    text:
                        "\n\nIt is developed by jixiaoyong. The design is based on ",
                  ),
                  TextSpan(
                      text: "a picture",
                      recognizer: TapGestureRecognizer()
                        ..onTap =
                            () => openUrl("https://huaban.com/pins/4619822724"),
                      style: const TextStyle(color: Colors.blue)),
                  const TextSpan(
                    text: 'be found in the internet.',
                  ),
                  const TextSpan(
                    text: '\n\nIf you have any question, please contact me:',
                  ),
                ],
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              )),
            ),
            buildItemWidget(
                Icons.link_outlined, "Github", "https://github.com/jixiaoyong",
                () {
              openUrl("https://github.com/jixiaoyong");
            }),
            buildItemWidget(
                Icons.rocket_outlined, "Blog", "https://xiaoyong.ml/blog", () {
              openUrl("https://xiaoyong.ml/blog");
            }),
            buildItemWidget(
                Icons.email_outlined, "Email", "jixiaoyong1995@gmail.com", () {
              openUrl("mailto:jixiaoyong1995@gmail.com");
            }),
            const Spacer(),
            Padding(
              padding: EdgeInsets.all(10.dp),
              child: Text(
                "Copyright (c) 2022 by jixiaoyong, All Rights Reserved.",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildItemWidget(
      IconData icon, String title, String content, GestureTapCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.dp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5.dp)),
                padding: EdgeInsets.all(5.dp),
                child: Icon(icon)),
            Padding(
              padding: EdgeInsets.only(left: 10.dp),
              child: Text(title),
            ),
            Expanded(
                child: Text(
              content,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  color: Colors.grey, fontStyle: FontStyle.italic),
            )),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 10.dp,
            )
          ],
        ),
      ),
    );
  }

  void openUrl(String url) {
    launchUrl(Uri.parse(url));
  }
}
