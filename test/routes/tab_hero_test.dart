import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/wallet/presentation/history_details_page.dart';
import 'package:sirc/routes/app_router.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/widgets/network_web_image.dart';

void main() {
  testWidgets('真实Tab切换无隐藏头像飞行，主从详情保留交易及Hero身份', (tester) async {
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
      initialLocation: AppRoutes.WALLET,
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

    // 普通图片位于所属 Navigator 的页面中；Hero shuttle 位于该
    // Navigator 的 Overlay 中，不再继承它的页面路由。分支 Overlay
    // 仍在 MainPage 内，不能用 MainPage 祖先来排除飞行图片。
    final flyingImages = find
        .byWidgetPredicate((widget) => widget is NetworkWebImage)
        .evaluate;
    int flightCount() => flyingImages().where((element) {
      final navigator = element.findAncestorStateOfType<NavigatorState>();
      return navigator != null &&
          ModalRoute.of(element)?.navigator != navigator;
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
    final tag = tester.widget<Hero>(hero).tag;
    await tester.ensureVisible(hero);
    await tester.tap(hero);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(flightCount(), 0, reason: '主从详情不跨左右窗格飞行');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.byType(HistoryDetailsPage), findsOneWidget);
    final detail = tester.widget<HistoryDetailsPage>(
      find.byType(HistoryDetailsPage),
    );
    expect(detail.heroTag, tag);
    expect(detail.data.moneyActionName, isNotEmpty);
    expect(detail.data.moneyAmount, isNotNull);
    expect(flightCount(), 0);
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(flightCount(), 0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(flightCount(), 0);
    expect(find.byType(HistoryDetailsPage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
