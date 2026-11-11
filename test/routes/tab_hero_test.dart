import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/wallet/presentation/transaction_detail_page.dart';
import 'package:sirc/routes/app_router.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/widgets/network_web_image.dart';

void main() {
  testWidgets('窄屏个人交易Hero真实往返，跨断点保留来源与详情状态', (tester) async {
    SharedPreferences.setMockInitialValues({CommonKeys.IS_LOGIN_SUCCESS: true});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final router = createAppRouter(
      container.read(storageServiceProvider),
      initialLocation: AppRoutes.PERSON,
    );
    addTearDown(router.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(839, 600);
    addTearDown(tester.view.reset);
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
    int flights() => find.byType(NetworkWebImage).evaluate().where((element) {
      final navigator = element.findAncestorStateOfType<NavigatorState>();
      return navigator != null &&
          ModalRoute.of(element)?.navigator != navigator;
    }).length;
    final hero = find.byType(Hero).first;
    final source = tester.element(hero);
    final tag = tester.widget<Hero>(hero).tag;
    await tester.ensureVisible(hero);
    final sourceScrolls = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .toList();
    for (final scroll in sourceScrolls) {
      if (scroll.position.maxScrollExtent > 24) scroll.position.jumpTo(24);
    }
    await tester.pump();
    final sourceOffsets = [
      for (final scroll in sourceScrolls) scroll.position.pixels,
    ];
    await tester.tap(hero);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(flights(), greaterThan(0), reason: 'push中间帧必须真的有头像飞行');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    final detail = tester.element(find.byType(TransactionDetailPage));
    expect((detail.widget as TransactionDetailPage).heroTag, tag);
    for (final width in [840.0, 839.0, 840.0, 839.0]) {
      tester.view.physicalSize = Size(width, 600);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(tester.element(find.byType(TransactionDetailPage)), same(detail));
      expect(
        find
            .byWidgetPredicate(
              (w) => w is Hero && w.tag == tag,
              skipOffstage: false,
            )
            .evaluate()
            .any((e) => identical(e, source)),
        isTrue,
      );
      expect(flights(), 0);
      expect(tester.takeException(), isNull);
    }
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(flights(), greaterThan(0), reason: 'pop中间帧必须真的有头像飞行');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.byType(TransactionDetailPage), findsNothing);
    expect(
      tester.element(find.byWidgetPredicate((w) => w is Hero && w.tag == tag)),
      same(source),
    );
    expect([
      for (final scroll in sourceScrolls) scroll.position.pixels,
    ], sourceOffsets);
    expect(flights(), 0);
    expect(tester.takeException(), isNull);
  });
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
    expect(find.byType(TransactionDetailPage), findsOneWidget);
    final detail = tester.widget<TransactionDetailPage>(
      find.byType(TransactionDetailPage),
    );
    expect(detail.heroTag, tag);
    expect(detail.data!.moneyActionName, isNotEmpty);
    expect(detail.data!.moneyAmount, isNotNull);
    expect(flightCount(), 0);
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(flightCount(), 0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(flightCount(), 0);
    expect(find.byType(TransactionDetailPage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
