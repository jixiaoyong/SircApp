import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// Test-only platform doubles keep embedded HTML independent of native plugins.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:sirc/features/settings/presentation/about_page.dart';
import 'package:sirc/widgets/settings_item_tile.dart';

class _WebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) => _Controller(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => _Delegate(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _WebViewWidget(params);
}

class _Controller extends PlatformWebViewController {
  _Controller(super.params) : super.implementation();

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}
  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {}
  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}
  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}
}

class _Delegate extends PlatformNavigationDelegate {
  _Delegate(super.params) : super.implementation();

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {}
  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}
}

class _WebViewWidget extends PlatformWebViewWidget {
  _WebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class _RecordingAboutPage extends AboutPage {
  const _RecordingAboutPage(this.openedUrls);
  final List<String> openedUrls;

  @override
  void openUrl(BuildContext context, String url) => openedUrls.add(url);
}

void main() {
  late WebViewPlatform? originalPlatform;
  setUp(() {
    originalPlatform = WebViewPlatform.instance;
    WebViewPlatform.instance = _WebViewPlatform();
  });
  tearDown(() {
    if (originalPlatform != null) {
      WebViewPlatform.instance = originalPlatform!;
    }
  });

  for (final width in [320.0, 1440.0]) {
    testWidgets('About共享尺寸、链接内容和点击目标保持不变 $width', (tester) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final urls = <String>[];
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: _RecordingAboutPage(urls))),
      );
      await tester.pumpAndSettle();
      final tiles = find.byType(SettingsItemTile);
      expect(tiles, findsNWidgets(3));
      final expectedUrls = [
        'https://github.com/jixiaoyong',
        'https://jixiaoyong.github.io',
        'mailto:jixiaoyong1995@gmail.com',
      ];
      for (var index = 0; index < 3; index++) {
        final shared = tester.widget<SettingsItemTile>(tiles.at(index));
        final row = find.descendant(
          of: tiles.at(index),
          matching: find.byType(ListTile),
        );
        final tile = tester.widget<ListTile>(row);
        await tester.ensureVisible(row);
        expect(tester.getSize(row).height, greaterThanOrEqualTo(64));
        expect(
          tester.getSize(find.byWidget(tile.leading!)),
          const Size(36, 36),
        );
        expect(
          tester.getSize(
            find.descendant(
              of: find.byWidget(tile.leading!),
              matching: find.byType(Icon),
            ),
          ),
          const Size(20, 20),
        );
        expect(
          shared.subtitle,
          expectedUrls[index].replaceFirst('mailto:', ''),
        );
        expect(find.text(shared.subtitle!), findsOneWidget);
        final material = tester.widget<Material>(
          find.ancestor(of: row, matching: find.byType(Material)).first,
        );
        expect(material.clipBehavior, Clip.antiAlias);
        expect(material.borderRadius, BorderRadius.circular(14));
        await tester.tap(
          find.descendant(of: row, matching: find.text(shared.title)),
        );
        await tester.pumpAndSettle();
        expect(urls, expectedUrls.take(index + 1).toList());
        expect(tester.takeException(), isNull);
      }
    });
  }
}
