import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_locale.dart';
import '../../../gen_a/A.dart';
import '../../../utils/size_extension.dart';
import '../../../widgets/one_title_with_back_button_appbar.dart';
import '../../../widgets/webview/embed/embed_webview.dart';
import '../../../widgets/webview/webview_page.dart';

/*
* @description: 关于我们页面（Riverpod 现代架构）
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/25 (Refactored to Riverpod 2.x)
*/
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听多语言变化以刷新文案
    ref.watch(localeProvider);

    final width = MediaQuery.of(context).size.width;
    final aboutText = "AboutUsDescription".tr;

    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: "About".tr,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
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
            SizedBox(
              height: 220.dp,
              child: IgnorePointer(
                child: EmbedWebView(
                  aboutText,
                  width,
                  maxHeight: 240,
                  backgroundColor: "#fafafa",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.dp),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "This is an open-source project hosted on ".tr,
                      children: [
                        TextSpan(
                          text: "Github.com/jixiaoyong/SircApp",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => openUrl(
                                  context,
                                  "https://github.com/jixiaoyong/SircApp",
                                ),
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    const TextSpan(
                      text:
                          ", supporting Android, iOS, and Web platforms.\nYou can try the online version: ",
                    ),
                    TextSpan(
                      text: "jixiaoyong.github.io/SircApp",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => openUrl(
                              context,
                              "https://jixiaoyong.github.io/SircApp",
                            ),
                      style: const TextStyle(color: Colors.blue),
                    ),
                    const TextSpan(
                      text:
                          "\n\nIt is developed by jixiaoyong. The design is based on ",
                    ),
                    TextSpan(
                      text: "a picture ",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => openUrl(
                              context,
                              "https://huaban.com/pins/4619822724",
                            ),
                      style: const TextStyle(color: Colors.blue),
                    ),
                    const TextSpan(
                      text: 'found on the internet.',
                    ),
                    const TextSpan(
                      text: '\n\nIf you have any questions, please contact me:',
                    ),
                  ],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            buildItemWidget(
              Icons.link_outlined,
              "Github",
              "https://github.com/jixiaoyong",
              () => openUrl(context, "https://github.com/jixiaoyong"),
            ),
            buildItemWidget(
              Icons.rocket_outlined,
              "Blog",
              "https://jixiaoyong.github.io",
              () => openUrl(context, "https://jixiaoyong.github.io"),
            ),
            buildItemWidget(
              Icons.email_outlined,
              "Email",
              "jixiaoyong1995@gmail.com",
              () => openUrl(context, "mailto:jixiaoyong1995@gmail.com"),
            ),
            SizedBox(height: 30.dp),
            Padding(
              padding: EdgeInsets.all(10.dp),
              child: Builder(
                builder: (context) {
                  final int currentYear = DateTime.now().year;
                  final String copyrightYear =
                      currentYear > 2022 ? "2022~$currentYear" : "2022";
                  return Text(
                    "Copyright (c) $copyrightYear by jixiaoyong, \nAll Rights Reserved.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItemWidget(
    IconData icon,
    String title,
    String content,
    GestureTapCallback? onTap,
  ) {
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
                borderRadius: BorderRadius.circular(5.dp),
              ),
              padding: EdgeInsets.all(5.dp),
              child: Icon(icon),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.dp),
              child: Text(title),
            ),
            Expanded(
              child: Text(
                content,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 10.dp,
            ),
          ],
        ),
      ),
    );
  }

  void openUrl(BuildContext context, String url) {
    if (url.startsWith("mailto:") || kIsWeb) {
      launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebViewPage(url),
        settings: const RouteSettings(name: '/webview'),
      ),
    );
  }
}
