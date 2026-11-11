import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_locale.dart';
import '../../../gen_a/A.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/one_title_with_back_button_appbar.dart';
import '../../../widgets/settings_item_tile.dart';

import 'package:embed_webview/embed_webview.dart';

import '../../../widgets/webview/webview_page.dart';

/*
* @description: 关于我们页面（Riverpod 现代架构）
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/25 (Refactored to Riverpod 2.x)
*/
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听多语言变化以刷新文案
    ref.watch(localeProvider);

    final aboutText = Languages.aboutUsDescription;

    return Scaffold(
      appBar: OneTitleWithBackButtonAppBar(
        title: Languages.about,
        onBack: onBack,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: Image.asset(
                  A.assets_ic_launcher,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: EmbedWebView(
                aboutText,
                backgroundColor:
                    '#${Theme.of(context).colorScheme.surface.toARGB32().toRadixString(16).substring(2)}',
                onLinkTap: (url) => openUrl(context, url),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: Languages.hostedOnGithub,
                      children: [
                        TextSpan(
                          text: "Github.com/jixiaoyong/SircApp",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => openUrl(
                              context,
                              "https://github.com/jixiaoyong/SircApp",
                            ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const TextSpan(
                      text: ", supporting Android, iOS, and Web platforms.\nYou can try the online version: ",
                    ),
                    TextSpan(
                      text: "jixiaoyong.github.io/SircApp",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => openUrl(
                          context,
                          "https://jixiaoyong.github.io/SircApp",
                        ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const TextSpan(
                      text: "\n\nIt is developed by jixiaoyong. The design is based on ",
                    ),
                    TextSpan(
                      text: "a picture ",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => openUrl(
                          context,
                          "https://huaban.com/pins/4619822724",
                        ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const TextSpan(text: 'found on the internet.'),
                    const TextSpan(
                      text: '\n\nIf you have any questions, please contact me:',
                    ),
                  ],
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SettingsItemTile(
                    icon: Icons.link_outlined,
                    title: "Github",
                    subtitle: "https://github.com/jixiaoyong",
                    onTap: () =>
                        openUrl(context, "https://github.com/jixiaoyong"),
                  ),
                  SettingsItemTile(
                    icon: Icons.rocket_outlined,
                    title: "Blog",
                    subtitle: "https://jixiaoyong.github.io",
                    onTap: () =>
                        openUrl(context, "https://jixiaoyong.github.io"),
                  ),
                  SettingsItemTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    subtitle: "jixiaoyong1995@gmail.com",
                    onTap: () =>
                        openUrl(context, "mailto:jixiaoyong1995@gmail.com"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.all(10),
              child: Builder(
                builder: (context) {
                  final int currentYear = DateTime.now().year;
                  final String copyrightYear = currentYear > 2022
                      ? "2022~$currentYear"
                      : "2022";
                  return Text(
                    "Copyright (c) $copyrightYear by jixiaoyong, \nAll Rights Reserved.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  void openUrl(BuildContext context, String url) {
    if (url.startsWith("mailto:") || kIsWeb) {
      launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebViewPage(url),
        settings: const RouteSettings(name: AppRoutes.WEBVIEW),
      ),
    );
  }
}
