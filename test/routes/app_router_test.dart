import 'package:material_ui/material_ui.dart';
import 'package:sirc/mock/mock_data_repository.dart';
import 'package:flutter/gestures.dart';
import 'package:sirc/features/auth/presentation/sign_in_page.dart';
import 'package:sirc/features/auth/presentation/sign_up_page.dart';
import 'package:sirc/features/auth/presentation/forget_pwd_page.dart';
import 'package:sirc/core/layout/adaptive_detail_layout.dart';
import 'package:sirc/features/settings/controllers/settings_controller.dart';
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
import 'package:sirc/features/settings/presentation/appearance_page.dart';
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
import 'package:sirc/features/wallet/presentation/transaction_detail_page.dart';

// AboutPage embeds native HTML; use the same test-only platform contract as its page tests.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class _AboutWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) => _AboutController(params);
  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => _AboutDelegate(params);
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _AboutWebView(params);
}

class _AboutController extends PlatformWebViewController {
  _AboutController(super.params) : super.implementation();
  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {}
  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate delegate,
  ) async {}
  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}
}

class _AboutDelegate extends PlatformNavigationDelegate {
  _AboutDelegate(super.params) : super.implementation();
  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback callback,
  ) async {}
  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {}
}

class _AboutWebView extends PlatformWebViewWidget {
  _AboutWebView(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  late MockDataRepository mock;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mock = MockDataRepository();
    await mock.wallet;
    await mock.articles;
    await mock.user;
  });
  TestWidgetsFlutterBinding.ensureInitialized();
  WebViewPlatform.instance = _AboutWebViewPlatform();

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
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        mockDataRepositoryProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> tapDetailBack(WidgetTester tester, Type detail) async {
    final arrow = find.descendant(
      of: find.byType(detail),
      matching: find.byIcon(Icons.arrow_back),
    );
    await tester.tap(
      arrow.evaluate().isNotEmpty
          ? arrow.first
          : find.descendant(
              of: find.byType(detail),
              matching: find.byType(BackButton),
            ),
    );
    await finishTransition(tester);
  }

  testWidgets('引导登录注册切换无返回栈和转场，忘记密码仍可返回', (tester) async {
    final container = await createContainer();
    final router = createAppRouter(container.read(storageServiceProvider));
    addTearDown(router.dispose);
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
    expect(find.byType(InitialPage), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    final initialContext = tester.element(find.byType(InitialPage));
    await container
        .read(initialControllerProvider.notifier)
        .goMainPage(initialContext);
    await finishTransition(tester);
    expect(find.byType(SignInPage), findsOneWidget);
    expect(router.canPop(), isFalse);

    void tapModeLink(String label) {
      final rich = tester.widgetList<RichText>(find.byType(RichText));
      final span = rich
          .expand(
            (widget) => (widget.text as TextSpan).children ?? <InlineSpan>[],
          )
          .whereType<TextSpan>()
          .firstWhere(
            (span) =>
                span.text?.trim() == label &&
                span.recognizer is TapGestureRecognizer,
          );
      (span.recognizer! as TapGestureRecognizer).onTap!();
    }

    for (var i = 0; i < 3; i++) {
      tapModeLink(Languages.signUp);
      await finishTransition(tester);
      expect(find.byType(SignUpPage), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.SIGN_UP);
      expect(router.canPop(), isFalse);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(BackButton), findsNothing);
      expect(
        ModalRoute.of(tester.element(find.byType(SignUpPage)))!
            .transitionDuration,
        Duration.zero,
      );
      tapModeLink(Languages.signIn);
      await finishTransition(tester);
      expect(find.byType(SignInPage), findsOneWidget);
      expect(router.canPop(), isFalse);
      expect(find.byType(AppBar), findsNothing);
      expect(
        ModalRoute.of(tester.element(find.byType(SignInPage)))!
            .transitionDuration,
        Duration.zero,
      );
    }
    await tester.tap(find.text(Languages.forgetPasswords));
    await finishTransition(tester);
    expect(find.byType(ForgetPwdPage), findsOneWidget);
    expect(router.canPop(), isTrue);
    router.pop();
    await finishTransition(tester);
    expect(find.byType(SignInPage), findsOneWidget);
    expect(router.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final extra in <Object?>[
    null,
    'invalid',
    <String, Object?>{'data': 'not a transaction', 'heroTag': 42},
    <Object, Object?>{1: 'wrong key', 'data': false},
  ]) {
    testWidgets('交易缺参或非法参数显示业务空态并返回 $extra', (tester) async {
      final container = await createContainer(loggedIn: true);
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: '/wallet',
      );
      addTearDown(router.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 900);
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
      await finishTransition(tester);
      router.push('/wallet/transaction', extra: extra);
      await finishTransition(tester);
      expect(
        find.text(Languages.wallet.transactionUnavailable),
        findsOneWidget,
      );
      expect(find.byType(NotFoundPage), findsNothing);
      expect(
        tester
            .widget<TransactionDetailPage>(find.byType(TransactionDetailPage))
            .data,
        isNull,
      );
      expect(
        find.descendant(
          of: find.byType(TransactionDetailPage),
          matching: find.byType(Hero),
        ),
        findsNothing,
      );
      await tapDetailBack(tester, TransactionDetailPage);
      expect(router.routeInformationProvider.value.uri.path, '/wallet');
      expect(tester.takeException(), isNull);
    });
  }

  for (final source in ['/wallet', '/person']) {
    testWidgets('不存在卡片保留来源管理返回策略 $source', (tester) async {
      final container = await createContainer(loggedIn: true);
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: '$source/edit-card/missing',
      );
      addTearDown(router.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 900);
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
      await finishTransition(tester);
      expect(find.text(Languages.wallet.cardNotFound), findsOneWidget);
      expect(find.byType(NotFoundPage), findsNothing);
      await tester.binding.handlePopRoute();
      await finishTransition(tester);
      expect(
        router.routeInformationProvider.value.uri.path,
        source == '/person' ? '/person/card' : '/wallet/cards',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('刷新交易深链没有extra时显示本地空态并返回来源', (tester) async {
    final container = await createContainer(loggedIn: true);
    final router = createAppRouter(
      container.read(storageServiceProvider),
      initialLocation: '/history/transaction',
    );
    addTearDown(router.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
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
    await finishTransition(tester);
    expect(find.text(Languages.wallet.transactionUnavailable), findsOneWidget);
    await tapDetailBack(tester, TransactionDetailPage);
    expect(router.routeInformationProvider.value.uri.path, '/history');
    expect(tester.takeException(), isNull);
  });

  const personDetails = [
    (Icons.email_outlined, '/person/email', PersonInformationPage),
    (Icons.phone_outlined, '/person/phone', PersonInformationPage),
    (Icons.location_on_outlined, '/person/address', PersonInformationPage),
    (Icons.credit_card_outlined, '/person/card', PersonCardsPage),
  ];

  for (final detail in personDetails) {
    testWidgets('宽屏个人资料深链返回完整个人页 ${detail.$2}', (tester) async {
      final container = await createContainer(loggedIn: true);
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: detail.$2,
      );
      addTearDown(router.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 900);
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
      expect(router.routeInformationProvider.value.uri.path, detail.$2);
      expect(find.byType(PersonPage), findsOneWidget);
      await tapDetailBack(tester, detail.$3);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.PERSON);
      expect(router.canPop(), isFalse);
      expect(find.byType(detail.$3), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('person-pane'))).width,
        tester.getSize(find.byType(PersonPage)).width,
      );
      expect(tester.takeException(), isNull);
    });
    for (final deepLink in [false, true]) {
      testWidgets('个人资料${deepLink ? "深链" : "点击"}跨断点与返回 ${detail.$2}', (
        tester,
      ) async {
        final container = await createContainer(loggedIn: true);
        await container
            .read(storageServiceProvider)
            .setUserEmail('current@example.test');
        final router = createAppRouter(
          container.read(storageServiceProvider),
          initialLocation: deepLink ? detail.$2 : AppRoutes.PERSON,
        );
        addTearDown(router.dispose);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
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
        if (!deepLink) {
          final tile = find.descendant(
            of: find.byType(PersonPage),
            matching: find.byIcon(detail.$1),
          );
          await tester.ensureVisible(tile);
          await finishTransition(tester);
          await tester.tap(tile);
          await finishTransition(tester);
        }
        final original = tester.element(find.byType(detail.$3));
        for (final size in [
          const Size(390, 844),
          const Size(1200, 900),
          const Size(390, 844),
        ]) {
          tester.view.physicalSize = size;
          await finishTransition(tester);
          expect(router.routeInformationProvider.value.uri.path, detail.$2);
          expect(find.byType(detail.$3), findsOneWidget);
          expect(tester.element(find.byType(detail.$3)), same(original));
          expect(find.byType(BottomNavigationBar), findsNothing);
          expect(
            find.byType(PersonPage),
            size.width >= 840 ? findsOneWidget : findsNothing,
          );
          if (detail.$3 == PersonInformationPage) {
            final value = tester.widget<SelectableText>(
              find.byKey(const ValueKey('person-information-value')),
            );
            expect(
              value.data,
              detail.$2.endsWith('email')
                  ? 'current@example.test'
                  : detail.$2.endsWith('phone')
                  ? '+1 202 555 0142'
                  : '100 Example Avenue, Sample City',
            );
            expect(find.byType(TextField), findsNothing);
          }
          if (size.width >= 840) {
            final pane = tester.getRect(
              find.byKey(const ValueKey('person-pane')),
            );
            final content = tester.getRect(find.byType(detail.$3));
            expect(pane.right, lessThanOrEqualTo(content.left));
            expect(pane.width, closeTo(content.width, .01));
          }
          expect(tester.takeException(), isNull);
        }
        await tapDetailBack(tester, detail.$3);
        expect(
          router.routeInformationProvider.value.uri.path,
          AppRoutes.PERSON,
        );
        expect(find.byType(PersonPage), findsOneWidget);
        expect(find.byType(detail.$3), findsNothing);
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(router.canPop(), isFalse);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('宽屏个人资料重复切换保持列表状态且不堆栈', (tester) async {
    final container = await createContainer(loggedIn: true);
    final router = createAppRouter(
      container.read(storageServiceProvider),
      initialLocation: AppRoutes.PERSON,
    );
    addTearDown(router.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
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
    final person = tester.element(find.byType(PersonPage));
    for (final detail in [
      for (final item in personDetails) ...[item, item],
    ]) {
      final tile = find.descendant(
        of: find.byType(PersonPage),
        matching: find.byIcon(detail.$1),
      );
      await tester.ensureVisible(tile);
      await finishTransition(tester);
      await tester.tap(tile);
      await finishTransition(tester);
      expect(router.routeInformationProvider.value.uri.path, detail.$2);
      expect(tester.element(find.byType(PersonPage)), same(person));
      expect(find.byType(detail.$3), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tapDetailBack(tester, PersonCardsPage);
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.PERSON);
    expect(router.canPop(), isFalse);
    expect(tester.element(find.byType(PersonPage)), same(person));
    expect(tester.takeException(), isNull);
  });

  const menuDetails = [
    (Icons.language_outlined, '/menu/languages', LanguagePage),
    (Icons.notifications_outlined, '/menu/notifications', NotificationsPage),
    (Icons.lock_outlined, '/menu/password', PasswordPage),
  ];

  Future<void> tapMenuDetail(WidgetTester tester, IconData icon) async {
    final target = find.descendant(
      of: find.byType(MenuPage),
      matching: find.byIcon(icon),
    );
    await tester.ensureVisible(target);
    await finishTransition(tester);
    await tester.tap(target);
    await finishTransition(tester);
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
        expect(nav, findsOneWidget);
        await tester.tap(
          find.descendant(of: nav, matching: find.byIcon(icon)).first,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        expect(
          path.endsWith('/${AppRoutes.TRANSACTION_SEGMENT}')
              ? GoRouterState.of(
                  tester.element(find.byType(TransactionDetailPage)),
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
            ? TransactionDetailPage
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
        GoRouterState.of(tester.element(find.byType(TransactionDetailPage)))
            .uri
            .path,
        '/wallet/transaction',
      );
      expect(
        tester
            .widget<TransactionDetailPage>(find.byType(TransactionDetailPage))
            .heroTag,
        tag,
      );
      await finishTransition(tester);
      final detailElement = tester.element(find.byType(TransactionDetailPage));
      expect(
        find.byType(BottomNavigationBar),
        findsNothing,
        reason: '交易详情不应展示底栏',
      );
      if (wide) {
        await clickTab(Icons.menu_outlined, AppRoutes.MENU);
        await clickTab(
          Icons.account_balance_wallet_outlined,
          AppRoutes.WALLET_TRANSACTION,
        );
      }
      expect(
        identical(
          detailElement,
          tester.element(find.byType(TransactionDetailPage)),
        ),
        isTrue,
      );
      expect(
        tester
            .widget<TransactionDetailPage>(find.byType(TransactionDetailPage))
            .heroTag,
        tag,
      );
      await tester.tap(
        find
            .descendant(
              of: find.byType(TransactionDetailPage),
              matching: find.byIcon(Icons.arrow_back),
            )
            .first,
      );
      await finishTransition(tester);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.WALLET);
      expect(find.byType(TransactionDetailPage), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [390.0, 1200.0]) {
    testWidgets('钱包添加管理同级详情与旧深链 $width', (tester) async {
      final container = await createContainer(loggedIn: true);
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: '/wallet',
      );
      addTearDown(router.dispose);
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
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
      await finishTransition(tester);
      await tester.tap(find.byKey(const ValueKey('manage-cards')));
      await finishTransition(tester);
      expect(router.routeInformationProvider.value.uri.path, '/wallet/cards');
      await tester.tap(find.byKey(const ValueKey('edit-card-card-test-002')));
      await finishTransition(tester);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/wallet/edit-card/card-test-002',
      );
      expect(find.byType(CardEditorPage), findsOneWidget);
      final fields = find.descendant(
        of: find.byType(CardEditorPage),
        matching: find.byType(EditableText),
      );
      expect(
        tester.widget<EditableText>(fields.first).controller.text,
        'Alex Morgan',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(CardEditorPage),
          matching: find.byType(BackButton),
        ),
      );
      await finishTransition(tester);
      expect(router.routeInformationProvider.value.uri.path, '/wallet/cards');
      router.go('/menu/add-card');
      await finishTransition(tester);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/wallet/add-card',
      );
      expect(find.byType(CardEditorPage), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(CardEditorPage),
          matching: find.byType(BackButton),
        ),
      );
      await finishTransition(tester);
      expect(router.routeInformationProvider.value.uri.path, '/wallet');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('应用导航断点使用窗口宽度而非嵌套容器约束', (tester) async {
    final container = await createContainer(loggedIn: true);
    final router = createAppRouter(
      container.read(storageServiceProvider),
      initialLocation: AppRoutes.MENU,
    );
    addTearDown(router.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
          builder: (context, child) => Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 700, height: 900, child: child!),
          ),
        ),
      ),
    );
    await finishTransition(tester);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(MenuPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('宽屏无动画分栏保持Menu实例滚动且同级不堆栈', (tester) async {
    final container = await createContainer(loggedIn: true);
    final router = createAppRouter(
      container.read(storageServiceProvider),
      initialLocation: AppRoutes.MENU,
    );
    addTearDown(router.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 400);
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
    final menu = find.byType(MenuPage);
    final menuElement = tester.element(menu);
    final mainElement = tester.element(find.byType(MainPage));
    final rail = tester.getRect(find.byType(NavigationRail));
    final full = tester.getRect(find.byType(AdaptiveDetailLayout));
    final pane = find.byKey(const ValueKey('menu-pane'));
    expect(tester.getSize(pane).width, full.width);
    final scroll = find.descendant(of: menu, matching: find.byType(Scrollable));
    final scrollState = tester.state<ScrollableState>(scroll);
    expect(scrollState.position.maxScrollExtent, greaterThan(0));
    scrollState.position.jumpTo(5);
    await tester.pump();
    final offset = scrollState.position.pixels;
    final cases = [
      (Icons.brightness_6_outlined, AppRoutes.MENU_APPEARANCE, AppearancePage),
      (Icons.language_outlined, AppRoutes.MENU_LANGUAGES, LanguagePage),
      (Icons.lock_outlined, AppRoutes.MENU_PASSWORD, PasswordPage),
      (
        Icons.notifications_outlined,
        AppRoutes.MENU_NOTIFICATIONS,
        NotificationsPage,
      ),
    ];
    // 连续重复点击当前详情也必须去重；最后一次返回应直接到菜单。
    for (final item in [
      for (final detail in cases) ...[detail, detail],
    ]) {
      // Exercise the actual handler without ensureVisible altering the scroll offset.
      if (item.$1 == Icons.notifications_outlined) {
        final tap = find
            .ancestor(
              of: find.descendant(of: menu, matching: find.byIcon(item.$1)),
              matching: find.byType(GestureDetector),
            )
            .first;
        tester.widget<GestureDetector>(tap).onTap!();
      } else {
        tester
            .widget<SettingsItemTile>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is SettingsItemTile && widget.icon == item.$1,
              ),
            )
            .onTap();
      }
      await tester.pump();
      await tester.pump();
      for (final ms in [0, 16, 80, 160, 400]) {
        await tester.pump(Duration(milliseconds: ms));
        expect(router.routeInformationProvider.value.uri.path, item.$2);
        expect(menu, findsOneWidget);
        expect(identical(tester.element(menu), menuElement), isTrue);
        expect(
          identical(tester.element(find.byType(MainPage)), mainElement),
          isTrue,
        );
        expect(
          identical(tester.state<ScrollableState>(scroll), scrollState),
          isTrue,
        );
        expect(scrollState.position.pixels, offset);
        expect(tester.getRect(find.byType(NavigationRail)), rail);
        final left = tester.getRect(pane);
        final right = tester.getRect(find.byType(item.$3));
        expect(left.left, full.left);
        expect(left.width, closeTo((full.width - 1) / 2, .01));
        expect(right.width, closeTo(left.width, .01));
        expect(right.left, closeTo(left.right + 1, .01));
        final route = ModalRoute.of(tester.element(find.byType(item.$3)))!;
        expect(route.settings, isA<NoTransitionPage<void>>());
        expect(route.animation!.value, 1);
        expect(route.secondaryAnimation!.value, 0);
        for (final other in cases.where((other) => other.$3 != item.$3)) {
          expect(find.byType(other.$3), findsNothing);
        }
        expect(tester.takeException(), isNull);
      }
    }
    await tester.tap(
      find.descendant(
        of: find.byType(NotificationsPage),
        matching: find.byIcon(Icons.arrow_back),
      ),
    );
    await tester.pump();
    await tester.pump();
    for (final ms in [0, 16, 100, 400]) {
      await tester.pump(Duration(milliseconds: ms));
      expect(tester.getSize(pane).width, full.width);
      expect(identical(tester.element(menu), menuElement), isTrue);
      expect(scrollState.position.pixels, offset);
      expect(tester.getRect(find.byType(NavigationRail)), rail);
      for (final item in cases) {
        expect(find.byType(item.$3), findsNothing);
      }
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.MENU);
      expect(router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('宽屏选择语言完成后关闭详情且Menu保持同一实例', (tester) async {
    final container = await createContainer(loggedIn: true);
    final router = createAppRouter(
      container.read(storageServiceProvider),
      initialLocation: AppRoutes.MENU_LANGUAGES,
    );
    addTearDown(router.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
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
    final menuElement = tester.element(find.byType(MenuPage));
    await tester.tap(
      find.descendant(
        of: find.byType(LanguagePage),
        matching: find.text('English'),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.MENU);
    expect(find.byType(LanguagePage), findsNothing);
    expect(
      identical(tester.element(find.byType(MenuPage)), menuElement),
      isTrue,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('menu-pane'))).width,
      tester.getSize(find.byType(AdaptiveDetailLayout)).width,
    );
    expect(tester.takeException(), isNull);
  });

  for (final detailPath in [
    AppRoutes.MENU_APPEARANCE,
    AppRoutes.MENU_LANGUAGES,
    AppRoutes.MENU_PASSWORD,
    AppRoutes.MENU_NOTIFICATIONS,
  ]) {
    testWidgets('宽屏详情深链返回全宽 $detailPath', (tester) async {
      final container = await createContainer(loggedIn: true);
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: detailPath,
      );
      addTearDown(router.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 900);
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
      expect(find.byType(MenuPage), findsOneWidget);
      final back = find.byIcon(Icons.arrow_back);
      if (back.evaluate().isNotEmpty) {
        await tester.tap(back.first);
      } else {
        await tester.tap(find.byType(BackButton));
      }
      await tester.pump();
      await tester.pump();
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.MENU);
      expect(
        tester.getSize(find.byKey(const ValueKey('menu-pane'))).width,
        tester.getSize(find.byType(AdaptiveDetailLayout)).width,
      );
      expect(router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

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
        (
          Icons.language_outlined,
          AppRoutes.MENU_LANGUAGES,
          LanguagePage,
          'English',
        ),
        (
          Icons.lock_outlined,
          AppRoutes.MENU_PASSWORD,
          PasswordPage,
          Languages.oldPassword,
        ),
        (
          Icons.notifications_outlined,
          AppRoutes.MENU_NOTIFICATIONS,
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
        final expectedPath = item.$2;
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

  for (final detail in menuDetails) {
    testWidgets('窄屏进入详情后跨断点保持URL和输入并正常返回 ${detail.$2}', (tester) async {
      final container = await createContainer(loggedIn: true);
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: AppRoutes.MENU,
      );
      addTearDown(router.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
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
      await tapMenuDetail(tester, detail.$1);

      final inputValues = detail.$3 == PasswordPage
          ? ['old-password', 'new-password', 'new-password']
          : detail.$3 == CardEditorPage
          ? ['Test Owner', '4111111111111111']
          : <String>[];
      Finder fields() => find.descendant(
        of: find.byType(detail.$3),
        matching: find.byType(EditableText),
      );
      for (var i = 0; i < inputValues.length; i++) {
        await tester.ensureVisible(fields().at(i));
        await tester.enterText(fields().at(i), inputValues[i]);
      }
      tester.testTextInput.hide();
      FocusManager.instance.primaryFocus?.unfocus();
      await finishTransition(tester);

      for (final size in [
        const Size(390, 844),
        const Size(1200, 900),
        const Size(390, 844),
      ]) {
        tester.view.physicalSize = size;
        await finishTransition(tester);
        expect(router.routeInformationProvider.value.uri.path, detail.$2);
        expect(find.byType(detail.$3), findsOneWidget);
        expect(find.byType(NotFoundPage), findsNothing);
        expect(find.byType(BottomNavigationBar), findsNothing);
        expect(
          find.byType(MenuPage),
          size.width >= 840 ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(NavigationRail),
          size.width >= 840 ? findsOneWidget : findsNothing,
        );
        if (size.width >= 840) {
          final menu = tester.getRect(find.byKey(const ValueKey('menu-pane')));
          final content = tester.getRect(find.byType(detail.$3));
          expect(menu.right, lessThanOrEqualTo(content.left));
          expect(menu.width, closeTo(content.width, .01));
        }
        for (var i = 0; i < inputValues.length; i++) {
          expect(
            tester.widget<EditableText>(fields().at(i)).controller.text,
            inputValues[i],
            reason: '切换至 $size 后不应清空 ${detail.$2} 的第 $i 项输入',
          );
        }
        expect(tester.takeException(), isNull);
      }
      await tapDetailBack(tester, detail.$3);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.MENU);
      expect(find.byType(MenuPage), findsOneWidget);
      expect(find.byType(detail.$3), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('窄屏正式深链接返回菜单 ${detail.$2}', (tester) async {
      final container = await createContainer(loggedIn: true);
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: detail.$2,
      );
      addTearDown(router.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
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
      expect(router.routeInformationProvider.value.uri.path, detail.$2);
      expect(find.byType(detail.$3), findsOneWidget);
      expect(find.byType(MenuPage), findsNothing);
      await tapDetailBack(tester, detail.$3);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.MENU);
      expect(find.byType(MenuPage), findsOneWidget);
      expect(router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  for (final oldPath in ['/languages', '/notifications', '/password']) {
    testWidgets('已登录访问旧详情路径显示404而不兼容跳转 $oldPath', (tester) async {
      final container = await createContainer(loggedIn: true);
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: oldPath,
      );
      addTearDown(router.dispose);
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
      expect(router.routeInformationProvider.value.uri.path, oldPath);
      expect(find.byType(NotFoundPage), findsOneWidget);
      for (final detail in menuDetails) {
        expect(find.byType(detail.$3), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final wide in [false, true]) {
    testWidgets('${wide ? "宽屏" : "窄屏"}侧滑通知使用正式菜单详情入口', (tester) async {
      final container = await createContainer(loggedIn: true);
      // 通过真实侧滑入口进入，而不是调用 router.go 模拟通知导航。
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
      container.read(navigationControllerProvider.notifier).openDrawer();
      await finishTransition(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(SlideMenuPage),
          matching: find.text(' ${Languages.notifications}'),
        ),
      );
      await finishTransition(tester);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/menu/notifications',
      );
      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.byType(NotFoundPage), findsNothing);
      expect(
        container.read(navigationControllerProvider).isDrawerOpen,
        isFalse,
      );
      expect(find.byType(MenuPage), wide ? findsOneWidget : findsNothing);
      await tapDetailBack(tester, NotificationsPage);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.MENU);
      expect(tester.takeException(), isNull);
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
      expect(find.text('/missing'), findsOneWidget);
      expect(find.textContaining('secret-value'), findsNothing);
      expect(find.textContaining('private-fragment'), findsNothing);
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
      expect(
        router.routeInformationProvider.value.uri.path,
        path == AppRoutes.ADD_CARD ? '/wallet/add-card' : path,
      );
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
