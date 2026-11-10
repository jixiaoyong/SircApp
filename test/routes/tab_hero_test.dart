import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/home/presentation/main_page.dart';
import 'package:sirc/features/wallet/presentation/history_details_page.dart';
import 'package:sirc/routes/app_router.dart';
import 'package:sirc/widgets/network_web_image.dart';

void main() {
  testWidgets('真实Tab切换不产生隐藏头像飞行，交易详情仍有Hero往返动画', (tester) async {
    SharedPreferences.setMockInitialValues({
      CommonKeys.IS_LOGIN_SUCCESS: true,
      CommonKeys.LOCAL_LANGUAGE: 'en_US',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final router = createAppRouter(
      container.read(storageServiceProvider),
      initialLocation: '/wallet',
    );
    addTearDown(router.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    // Hero默认shuttle复用目标头像，但飞行时不属于业务页面或Hero子树。
    final flyingImages = find
        .byWidgetPredicate((widget) => widget is NetworkWebImage)
        .evaluate;
    int flightCount() => flyingImages().where((element) {
      var inPage = false;
      element.visitAncestorElements((ancestor) {
        if (ancestor.widget is MainPage ||
            ancestor.widget is HistoryDetailsPage) {
          inPage = true;
          return false;
        }
        return true;
      });
      return !inPage;
    }).length;

    for (final icon in [
      Icons.person_outline_outlined,
      Icons.av_timer_outlined,
      Icons.menu_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.person_outline_outlined,
      Icons.account_balance_wallet_outlined,
    ]) {
      final rail = find.byType(NavigationRail);
      await tester.tap(find.descendant(of: rail, matching: find.byIcon(icon)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(flightCount(), 0, reason: 'Tab切换不能让IndexedStack隐藏头像进入Overlay');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(flightCount(), 0);
      expect(tester.takeException(), isNull);
    }

    final hero = find.byType(Hero).first;
    await tester.ensureVisible(hero);
    await tester.tap(hero);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(flightCount(), greaterThan(0), reason: '钱包交易到详情仍应有正常Hero动画');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.byType(HistoryDetailsPage), findsOneWidget);
    expect(flightCount(), 0);
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(flightCount(), greaterThan(0));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(flightCount(), 0);
    expect(find.byType(HistoryDetailsPage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
