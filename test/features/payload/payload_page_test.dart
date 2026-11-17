import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/payload/payload_page.dart';
import 'package:sirc/features/payload/payload_runtime.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class _Runtime extends PayloadRuntime {
  int restores = 0;
  int activations = 0;
  @override
  Future<void> activateUpdate() async {
    activations++;
    version = availableVersion;
    availableVersion = null;
    data(
      'http://127.0.0.1:1234/__payload/new/companion/index.html',
      authUserAgent,
    );
  }

  int resumes = 0;
  @override
  Future<void> start() async {}
  @override
  Future<void> retry({bool restore = false}) async {
    if (restore) restores++;
    failed = false;
    notifyListeners();
  }

  @override
  Future<void> resume() async {
    resumes++;
  }

  void data(String value, String token) {
    url = value;
    authUserAgent = token;
    notifyListeners();
  }
}

class _Platform extends WebViewPlatform {
  late _Controller controller;
  late _Delegate delegate;
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) => controller = _Controller(params);
  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => delegate = _Delegate(params);
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _View(params);
}

class _Controller extends PlatformWebViewController {
  _Controller(super.params) : super.implementation();
  String? ua;
  final requests = <String>[];
  final scripts = <String>[];
  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams params,
  ) async {}
  @override
  Future<String?> getUserAgent() async => 'Native-UA';
  @override
  Future<void> setUserAgent(String? userAgent) async {
    ua = userAgent;
  }

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}
  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    requests.add(params.uri.toString());
  }

  @override
  Future<void> runJavaScript(String javaScript) async {
    scripts.add(javaScript);
  }

  @override
  Future<bool> canGoBack() async => false;
}

class _Delegate extends PlatformNavigationDelegate {
  _Delegate(super.params) : super.implementation();
  late PageEventCallback finished;
  late WebResourceErrorCallback error;
  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback callback,
  ) async {}
  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {
    finished = callback;
  }

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {
    error = callback;
  }
}

class _View extends PlatformWebViewWidget {
  _View(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) =>
      const SizedBox(key: ValueKey('native-payload-webview'));
}

void main() {
  for (final language in ['zh_CN', 'en_US']) {
    testWidgets('$language 原生加载错误重试、鉴权变化及进程恢复', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final platform = _Platform();
      WebViewPlatform.instance = platform;
      SharedPreferences.setMockInitialValues({
        CommonKeys.LOCAL_LANGUAGE: language,
      });
      final prefs = await SharedPreferences.getInstance();
      final runtime = _Runtime();
      addTearDown(runtime.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(home: PayloadPage(runtime: runtime)),
        ),
      );
      await tester.pump();
      expect(find.text(Languages.home.payloadLoading), findsOneWidget);
      runtime.data(
        'http://127.0.0.1:1234/companion/index.html',
        'WebPayloadManager/token1',
      );
      await tester.pump();
      expect(platform.controller.ua, 'Native-UA WebPayloadManager/token1');
      expect(platform.controller.requests.last, runtime.url);
      platform.delegate.finished(runtime.url!);
      await tester.pump();
      expect(find.text(Languages.home.payloadLoading), findsNothing);
      expect(
        platform.controller.scripts.last,
        contains(Languages.home.payloadHeading),
      );
      final loadsBeforeReady = platform.controller.requests.length;
      runtime.availableVersion = '1.1.0';
      runtime.syncStatus = 'ready';
      runtime.notifyListeners();
      await tester.pump();
      expect(platform.controller.requests.length, loadsBeforeReady);
      expect(runtime.activations, 0);
      expect(
        find.textContaining(Languages.home.payloadUpdateAvailable),
        findsOneWidget,
      );
      await tester.tap(find.text(Languages.home.payloadActivateUpdate));
      await tester.pump();
      expect(runtime.activations, 1);
      expect(platform.controller.requests.length, loadsBeforeReady + 1);
      expect(find.text(Languages.home.payloadActivateUpdate), findsNothing);
      platform.delegate.error(
        const WebResourceError(
          errorCode: -1,
          description: 'failed',
          isForMainFrame: true,
        ),
      );
      await tester.pump();
      expect(find.text(Languages.home.payloadError), findsOneWidget);
      await tester.tap(find.text(Languages.home.payloadRetry));
      await tester.pump();
      expect(find.text(Languages.home.payloadError), findsNothing);
      runtime.data(
        'http://127.0.0.1:4567/companion/index.html',
        'WebPayloadManager/token2',
      );
      await tester.pump();
      expect(platform.controller.ua, 'Native-UA WebPayloadManager/token2');
      expect(platform.controller.requests.last, runtime.url);
      platform.delegate.error(
        const WebResourceError(
          errorCode: -1,
          description: 'terminated',
          errorType: WebResourceErrorType.webContentProcessTerminated,
        ),
      );
      await tester.pump();
      expect(runtime.resumes, 1);
      await tester.tap(find.byTooltip(Languages.home.payloadRestore));
      await tester.pump();
      expect(runtime.restores, 1);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
