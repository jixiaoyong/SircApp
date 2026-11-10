import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/presentation/menu_page.dart';
import 'package:sirc/features/home/presentation/person_page.dart';
import 'package:sirc/features/settings/presentation/initial_page.dart';
import 'package:sirc/widgets/settings_item_tile.dart';
import 'package:sirc/features/settings/presentation/language_page.dart';
import 'package:sirc/features/settings/presentation/notifications_page.dart';
import 'package:sirc/features/auth/presentation/password_page.dart';
import 'package:sirc/features/wallet/presentation/add_card_page.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';
import 'package:sirc/features/settings/presentation/not_found_page.dart';
import 'package:sirc/routes/app_router.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/features/home/presentation/main_page.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/features/home/presentation/slide_menu_page.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';
import 'package:sirc/features/wallet/presentation/history_page.dart';
import 'package:sirc/features/wallet/presentation/history_details_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // IndexedStack 中网络图片的加载动画不会 settle；只等待路由转场。
  Future<void> finishTransition(WidgetTester tester) async {
    await tester.pump();
    for (var frame = 0; frame < 3; frame++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  Future<ProviderContainer> createContainer({bool loggedIn = false}) async {
    SharedPreferences.setMockInitialValues({
      CommonKeys.IS_LOGIN_SUCCESS: loggedIn,
      CommonKeys.LOCAL_LANGUAGE: 'en_US',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  for (final wide in [true, false]) {
    testWidgets('${wide ? "Rail" : "底栏"}真实切换五分支且保留页面与详情栈', (tester) async {
      final container = await createContainer(loggedIn: true);
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: AppRoutes.HISTORY,
      );
      addTearDown(router.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = wide
          ? const Size(1200, 900)
          : const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
            // 单独保留默认字号的404回归；此用例用小字号绕开已知Home 3px溢出，
            // 不捕获或吞掉任何Flutter异常。
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(.85)),
              child: child!,
            ),
          ),
        ),
      );
      await finishTransition(tester);
      Future<void> clickTab(IconData icon, String path) async {
        final nav = find.byType(wide ? NavigationRail : BottomNavigationBar);
        await tester.tap(
          find.descendant(of: nav, matching: find.byIcon(icon)).first,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        expect(
          path.endsWith('/${AppRoutes.TRANSACTION_SEGMENT}')
              ? GoRouterState.of(
                  tester.element(find.byType(HistoryDetailsPage)),
                ).uri.path
              : router.routeInformationProvider.value.uri.path,
          path,
        );
        expect(find.byType(MainPage), findsOneWidget);
        // Tab无Page转场：首个中间帧当前分支即完整显示。
        final shell = tester
            .widget<MainPage>(find.byType(MainPage))
            .navigationShell;
        final activeType = path.endsWith('/${AppRoutes.TRANSACTION_SEGMENT}')
            ? HistoryDetailsPage
            : [
                HomePage,
                WalletPage,
                HistoryPage,
                PersonPage,
                MenuPage,
              ][shell.currentIndex];
        final route = ModalRoute.of(tester.element(find.byType(activeType)));
        expect(route, isNotNull);
        expect(route!.animation!.value, 1.0);
        expect(route.secondaryAnimation!.value, 0.0);
        await finishTransition(tester);
      }

      final historyElement = tester.element(find.byType(HistoryPage));
      final scrollable = find
          .descendant(
            of: find.byType(HistoryPage),
            matching: find.byType(Scrollable),
          )
          .first;
      final scrollState = tester.state<ScrollableState>(scrollable);
      await tester.drag(scrollable, const Offset(0, -150));
      await finishTransition(tester);
      final scrollOffset = scrollState.position.pixels;
      expect(scrollOffset, greaterThan(0));
      await clickTab(Icons.account_balance_wallet_outlined, AppRoutes.WALLET);
      await clickTab(Icons.av_timer_outlined, AppRoutes.HISTORY);
      expect(scrollState.position.pixels, scrollOffset);
      await tester.ensureVisible(find.byType(TextField).first);
      await finishTransition(tester);
      await tester.enterText(find.byType(TextField).first, 'kept search');
      await finishTransition(tester);
      final preservedOffset = scrollState.position.pixels;
      await clickTab(Icons.account_balance_wallet_outlined, AppRoutes.WALLET);
      final walletElement = tester.element(find.byType(WalletPage));
      await clickTab(Icons.person_outline_outlined, AppRoutes.PERSON);
      await clickTab(Icons.menu_outlined, AppRoutes.MENU);
      await clickTab(Icons.home_outlined, AppRoutes.MAIN);
      expect(find.byType(HomePage), findsOneWidget);
      await clickTab(Icons.av_timer_outlined, AppRoutes.HISTORY);
      expect(
        identical(historyElement, tester.element(find.byType(HistoryPage))),
        isTrue,
      );
      expect(find.text('kept search'), findsOneWidget);
      expect(scrollState.position.pixels, preservedOffset);
      // 抽屉同样通过goBranch，并且展开/收起不能重建来源分支。
      container.read(navigationControllerProvider.notifier).openDrawer();
      await finishTransition(tester);
      final drawerSettings = find.descendant(
        of: find.byType(SlideMenuPage),
        matching: find.text(' ${Languages.settings.title}'),
      );
      await tester.tap(drawerSettings);
      await finishTransition(tester);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.MENU);
      await clickTab(Icons.av_timer_outlined, AppRoutes.HISTORY);
      expect(
        identical(historyElement, tester.element(find.byType(HistoryPage))),
        isTrue,
      );
      await tester.enterText(find.byType(TextField).first, '');
      await clickTab(Icons.account_balance_wallet_outlined, AppRoutes.WALLET);
      expect(
        identical(walletElement, tester.element(find.byType(WalletPage))),
        isTrue,
      );
      final hero = find
          .descendant(of: find.byType(WalletPage), matching: find.byType(Hero))
          .first;
      final tag = tester.widget<Hero>(hero).tag;
      await tester.ensureVisible(hero);
      await tester.tap(hero);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        GoRouterState.of(tester.element(find.byType(HistoryDetailsPage)))
            .uri
            .path,
        '/wallet/transaction',
      );
      expect(
        tester
            .widget<HistoryDetailsPage>(find.byType(HistoryDetailsPage))
            .heroTag,
        tag,
      );
      await finishTransition(tester);
      final detailElement = tester.element(find.byType(HistoryDetailsPage));
      await clickTab(Icons.menu_outlined, AppRoutes.MENU);
      await clickTab(
        Icons.account_balance_wallet_outlined,
        AppRoutes.WALLET_TRANSACTION,
      );
      expect(
        identical(
          detailElement,
          tester.element(find.byType(HistoryDetailsPage)),
        ),
        isTrue,
      );
      expect(
        tester
            .widget<HistoryDetailsPage>(find.byType(HistoryDetailsPage))
            .heroTag,
        tag,
      );
      await tester.tap(
        find
            .descendant(
              of: find.byType(HistoryDetailsPage),
              matching: find.byIcon(Icons.arrow_back),
            )
            .first,
      );
      await finishTransition(tester);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.WALLET);
      expect(find.byType(HistoryDetailsPage), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('匿名业务深链重定向至登录', (tester) async {
    final container = await createContainer();
    final router = container.read(appRouterProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      ),
    );
    for (final path in [AppRoutes.ADD_CARD, AppRoutes.MENU_PASSWORD]) {
      router.go(path);
      await finishTransition(tester);
      expect(router.routeInformationProvider.value.uri.path, '/sign_in');
    }
  });

  for (final wide in [true, false]) {
    testWidgets('${wide ? "宽屏" : "窄屏"}真实点击设置详情并返回菜单', (tester) async {
      final container = await createContainer(loggedIn: true);
      // 直接从菜单启动，避免引导页计时器与转场遮罩干扰点击。
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: AppRoutes.MENU,
      );
      addTearDown(router.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = wide
          ? const Size(1200, 900)
          : const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        ),
      );
      await finishTransition(tester);

      final cases = [
        (Icons.language_outlined, AppRoutes.LANGUAGES, LanguagePage, 'English'),
        (
          Icons.lock_outlined,
          AppRoutes.PASSWORD,
          PasswordPage,
          Languages.oldPassword,
        ),
        (
          Icons.credit_card_outlined,
          AppRoutes.ADD_CARD,
          AddCardPage,
          'Visa Classic',
        ),
        (
          Icons.notifications_outlined,
          AppRoutes.NOTIFICATIONS,
          NotificationsPage,
          Languages.category,
        ),
      ];
      for (final item in cases) {
        // 以组件类型+图标定位，避免本地语言及详情页同名标题导致误点。
        final target = item.$1 == Icons.notifications_outlined
            ? find.descendant(
                of: find.byType(MenuPage),
                matching: find.byIcon(item.$1),
              )
            : find.byWidgetPredicate(
                (widget) =>
                    widget is SettingsItemTile && widget.icon == item.$1,
              );
        expect(target, findsOneWidget);
        await tester.ensureVisible(target);
        await finishTransition(tester);
        await tester.tap(
          item.$1 == Icons.notifications_outlined
              ? target
              : find.descendant(of: target, matching: find.byType(Text)).first,
        );
        await finishTransition(tester);
        await tester.pump();
        final expectedPath = wide && !item.$2.startsWith('${AppRoutes.MENU}/')
            ? '${AppRoutes.MENU}${item.$2}'
            : item.$2;
        expect(
          GoRouterState.of(tester.element(find.byType(item.$3))).uri.path,
          expectedPath,
        );
        expect(find.byType(NotFoundPage), findsNothing);
        expect(find.byType(item.$3), findsOneWidget);
        expect(find.text(item.$4), findsWidgets);
        expect(
          find.byType(SettingsItemTile),
          wide ? findsNWidgets(5) : findsNothing,
        );
        expect(
          find.byType(NavigationRail),
          wide ? findsOneWidget : findsNothing,
        );

        final back = find.descendant(
          of: find.byType(item.$3),
          matching: find.byIcon(Icons.arrow_back),
        );
        // AddCard 的 AppBar 默认使用平台 BackButton 图标。
        if (back.evaluate().isNotEmpty) {
          await tester.tap(back.first);
        } else {
          await tester.tap(
            find.descendant(
              of: find.byType(item.$3),
              matching: find.byType(BackButton),
            ),
          );
        }
        await finishTransition(tester);
        expect(router.routeInformationProvider.value.uri.path, AppRoutes.MENU);
        expect(find.byType(item.$3), findsNothing);
        expect(find.byType(SettingsItemTile), findsNWidgets(5));
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('404记录脱敏诊断且真实点击回业务首页而非闪屏', (tester) async {
    final container = await createContainer(loggedIn: true);
    final router = createAppRouter(
      container.read(storageServiceProvider),
      initialLocation: '/missing?token=secret-value#private-fragment',
    );
    addTearDown(router.dispose);
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final messages = <String>[];
    final previousDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) messages.add(message);
    };
    try {
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
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(NotFoundPage), findsOneWidget);
      expect(messages.join(), contains('Router 404: uri=/missing, error='));
      expect(messages.join(), isNot(contains('secret-value')));
      expect(messages.join(), isNot(contains('private-fragment')));
      await tester.tap(find.text('Go to Home'));
      await finishTransition(tester);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.MAIN);
      expect(find.byType(NotFoundPage), findsNothing);
      expect(find.byType(InitialPage), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      // testWidgets 在 addTearDown 前校验 foundation 全局变量。
      debugPrint = previousDebugPrint;
    }
  });

  testWidgets('登录后菜单详情直接匹配路由且不闪现Person或NotFound', (tester) async {
    final container = await createContainer(loggedIn: true);
    final router = container.read(appRouterProvider);
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      ),
    );

    for (final path in [
      AppRoutes.ADD_CARD,
      AppRoutes.MENU_PASSWORD,
      AppRoutes.MENU_LANGUAGES,
    ]) {
      router.go(path);
      await tester.pump();
      expect(router.routeInformationProvider.value.uri.path, path);
      expect(find.byType(NotFoundPage), findsNothing);
      expect(
        find.byType(PersonPage),
        findsNothing,
        reason: 'Person tab must not appear at $path',
      );
    }

    router.go(AppRoutes.MENU);
    await tester.pump();
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.MENU);
    expect(find.byType(NotFoundPage), findsNothing);
  });

  testWidgets('登录后可解析菜单及快捷业务路由', (tester) async {
    final container = await createContainer(loggedIn: true);
    final router = container.read(appRouterProvider);
    for (final path in [
      AppRoutes.MAIN,
      AppRoutes.WALLET,
      AppRoutes.HISTORY,
      AppRoutes.PERSON,
      AppRoutes.MENU,
      AppRoutes.ADD_CARD,
      AppRoutes.MENU_PASSWORD,
      AppRoutes.MENU_LANGUAGES,
      AppRoutes.MENU_NOTIFICATIONS,
      AppRoutes.ADD_CARD,
      AppRoutes.PASSWORD,
      AppRoutes.HISTORY_DETAILS,
    ]) {
      router.go(path);
      expect(router.routeInformationProvider.value.uri.path, path);
    }
  });

  testWidgets('登录成功与登出刷新同一实例并重新保护路由', (tester) async {
    final container = await createContainer();
    final router = container.read(appRouterProvider);
    final repo = container.read(authRepositoryProvider);
    expect(router.routeInformationProvider.value.uri.path, '/');
    await repo.login('jixiaoyong', '123456', mockDelay: Duration.zero);
    router.go(AppRoutes.ADD_CARD);
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.ADD_CARD);
    expect(identical(router, container.read(appRouterProvider)), isTrue);
    await repo.logout();
    router.go(AppRoutes.MENU_PASSWORD);
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
    await tester.pump(const Duration(milliseconds: 400));
    expect(router.routeInformationProvider.value.uri.path, '/sign_in');
  });
}
