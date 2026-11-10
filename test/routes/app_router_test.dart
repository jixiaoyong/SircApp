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
    for (final path in ['/menu/add-card', '/menu/password']) {
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
        initialLocation: '/menu',
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
        (Icons.language_outlined, '/languages', LanguagePage, 'English'),
        (Icons.lock_outlined, '/password', PasswordPage, Languages.oldPassword),
        (
          Icons.credit_card_outlined,
          '/menu/add-card',
          AddCardPage,
          'Visa Classic',
        ),
        (
          Icons.notifications_outlined,
          '/notifications',
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
        final expectedPath = wide && !item.$2.startsWith('/menu/')
            ? '/menu${item.$2}'
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
        expect(router.routeInformationProvider.value.uri.path, '/menu');
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
    addTearDown(() => debugPrint = previousDebugPrint);
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
    expect(router.routeInformationProvider.value.uri.path, '/main');
    expect(find.byType(NotFoundPage), findsNothing);
    expect(find.byType(InitialPage), findsNothing);
    expect(tester.takeException(), isNull);
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
      '/menu/add-card',
      '/menu/password',
      '/menu/languages',
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

    router.go('/menu');
    await tester.pump();
    expect(router.routeInformationProvider.value.uri.path, '/menu');
    expect(find.byType(NotFoundPage), findsNothing);
  });

  testWidgets('登录后可解析菜单及快捷业务路由', (tester) async {
    final container = await createContainer(loggedIn: true);
    final router = container.read(appRouterProvider);
    for (final path in [
      '/main',
      '/wallet',
      '/history',
      '/person',
      '/menu',
      '/menu/add-card',
      '/menu/password',
      '/menu/languages',
      '/menu/notifications',
      '/menu/add-card',
      '/password',
      '/history_details',
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
    router.go('/menu/add-card');
    expect(router.routeInformationProvider.value.uri.path, '/menu/add-card');
    expect(identical(router, container.read(appRouterProvider)), isTrue);
    await repo.logout();
    router.go('/menu/password');
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
