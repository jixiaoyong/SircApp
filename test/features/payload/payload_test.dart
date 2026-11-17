import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/payload/payload_detail_page.dart';
import 'package:sirc/features/payload/payload_page.dart';
import 'package:sirc/features/payload/payload_runtime.dart';
import 'package:sirc/routes/app_router.dart';
import 'package:sirc/routes/app_routes.dart';

void main() {
  test('仅允许当前服务同源导航', () {
    final local = Uri.parse('http://127.0.0.1:1234/companion/index.html');
    expect(
      isPayloadNavigation(local.replace(fragment: '/detail'), local),
      isTrue,
    );
    for (final value in [
      'http://127.0.0.1:1235/x',
      'https://example.org',
      'javascript:alert(1)',
      'file:///tmp/a',
    ]) {
      expect(isPayloadNavigation(Uri.parse(value), local), isFalse);
    }
  });

  test('内置包清单包含入口且校验和匹配', () async {
    final manifest = jsonDecode(
      await File('assets/web_payload/version.json').readAsString(),
    ) as Map<String, dynamic>;
    expect(manifest['modules'][0]['key'], 'companion');
    final files = manifest['fileInfo']['files'] as List;
    expect(files, isNotEmpty);
    for (final file in files) {
      final bytes = await File('assets/web_payload/${file['path']}')
          .readAsBytes();
      expect(md5.convert(bytes).toString(), file['md5']);
    }
  });

  for (final locale in [const Locale('zh', 'CN'), const Locale('en', 'US')]) {
    testWidgets('${locale.languageCode} H5 独立路由及宽窄导航', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      SharedPreferences.setMockInitialValues({
        CommonKeys.IS_LOGIN_SUCCESS: true,
        CommonKeys.LOCAL_LANGUAGE:
            '${locale.languageCode}_${locale.countryCode}',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      container.read(localeProvider);
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: AppRoutes.PAYLOAD,
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            locale: locale,
            supportedLocales: AppLocale.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PayloadPage), findsOneWidget);
      expect(
        find.text(Languages.home.payloadPlatformUnsupported),
        findsOneWidget,
      );
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .items
            .length,
        6,
      );
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        5,
      );
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pump();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        5,
      );
      expect(find.byType(BottomNavigationBar), findsNothing);
    });
  }

  testWidgets('全屏子页面脱离底部导航栏并正确展示', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    SharedPreferences.setMockInitialValues({
      CommonKeys.IS_LOGIN_SUCCESS: true,
      CommonKeys.LOCAL_LANGUAGE: 'zh_CN',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final router = createAppRouter(
      container.read(storageServiceProvider),
      initialLocation: '${AppRoutes.PAYLOAD_DETAIL}?view=emergency&title=紧急卡片与全球救援',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(PayloadDetailPage), findsOneWidget);
    // 默认全屏，无原生 AppBar
    expect(find.byType(AppBar), findsNothing);
    // 全屏子页面脱离了 StatefulShellRoute，完全没有底部导航栏
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
  });
}
