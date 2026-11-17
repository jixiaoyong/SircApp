import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/home/presentation/menu_page.dart';
import 'package:sirc/features/settings/controllers/settings_controller.dart';
import 'package:sirc/features/settings/presentation/appearance_page.dart';
import 'package:sirc/main.dart';
import 'package:sirc/routes/app_router.dart';
import 'package:sirc/routes/app_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  late ProviderContainer container;
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      CommonKeys.IS_LOGIN_SUCCESS: true,
      CommonKeys.IS_FIRST_INITIAL: false,
      CommonKeys.LOCAL_LANGUAGE: 'en_US',
      CommonKeys.USER_NAME: 'keep user',
    });
    prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });
  tearDown(() => container.dispose());

  test('三态立即更新、重建持久化与未知值回退', () async {
    expect(container.read(themeModeProvider), ThemeMode.system);
    for (final mode in ThemeMode.values) {
      await container.read(themeModeProvider.notifier).setThemeMode(mode);
      expect(container.read(themeModeProvider), mode);
      expect(prefs.getString(CommonKeys.THEME_MODE), mode.name);
      final restarted = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      expect(restarted.read(themeModeProvider), mode);
      restarted.dispose();
    }
    await prefs.setString(CommonKeys.THEME_MODE, 'invalid');
    container.invalidate(themeModeProvider);
    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('登出和清除用户数据保留设备主题、不保留其他数据', () async {
    await container
        .read(themeModeProvider.notifier)
        .setThemeMode(ThemeMode.dark);
    final storage = container.read(storageServiceProvider);
    await storage.clearUser();
    expect(storage.themeMode, 'dark');
    await storage.clearUserData();
    expect(prefs.getKeys(), {CommonKeys.THEME_MODE});
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  for (final language in ['en', 'zh']) {
    for (final wide in [true, false]) {
      testWidgets('外观正式详情三态实时应用、返回和深链 $language wide=$wide', (tester) async {
        tester.view.physicalSize = Size(wide ? 1200 : 390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        tester.platformDispatcher.platformBrightnessTestValue =
            Brightness.light;
        container.read(localeProvider.notifier).setLocale(Locale(language));
        final router = container.read(appRouterProvider);
        router.go(AppRoutes.MENU);
        await tester.pumpWidget(
          UncontrolledProviderScope(container: container, child: const MyApp()),
        );
        await pump(tester);
        await tester.tap(find.byKey(const ValueKey('appearance-setting')));
        await pump(tester);
        expect(
          router.routeInformationProvider.value.uri.path,
          AppRoutes.MENU_APPEARANCE,
        );
        expect(find.byType(AppearancePage), findsOneWidget);
        expect(find.byType(SimpleDialog), findsNothing);
        expect(find.byType(MenuPage), wide ? findsOneWidget : findsNothing);
        if (wide) {
          final left = tester.getSize(find.byKey(const ValueKey('menu-pane')));
          final right = tester.getSize(find.byType(AppearancePage));
          expect(left.width, closeTo(right.width, .01));
          expect(
            ModalRoute.of(tester.element(find.byType(AppearancePage)))!
                .settings,
            isA<NoTransitionPage<void>>(),
          );
        }
        Brightness brightness() =>
            Theme.of(tester.element(find.byType(AppearancePage))).brightness;
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        await pump(tester);
        expect(brightness(), Brightness.dark);
        for (final mode in [
          ThemeMode.light,
          ThemeMode.dark,
          ThemeMode.system,
        ]) {
          final tile = find.byKey(ValueKey('theme-${mode.name}'));
          await tester.tap(tile);
          await pump(tester);
          expect(container.read(themeModeProvider), mode);
          expect(prefs.getString(CommonKeys.THEME_MODE), mode.name);
          expect(tester.widget<ListTile>(tile).selected, isTrue);
          expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
          expect(
            brightness(),
            mode == ThemeMode.light ? Brightness.light : Brightness.dark,
          );
          expect(container.read(appRouterProvider), same(router));
          expect(
            router.routeInformationProvider.value.uri.path,
            AppRoutes.MENU_APPEARANCE,
          );
          expect(container.read(storageServiceProvider).isLoginSuccess, isTrue);
        }
        await tester.tap(find.byIcon(Icons.arrow_back));
        await pump(tester);
        expect(router.routeInformationProvider.value.uri.path, AppRoutes.MENU);
        expect(router.canPop(), isFalse);
        // Direct deep link has a real menu parent even without an imperative push.
        router.go(AppRoutes.MENU_APPEARANCE);
        await pump(tester);
        await tester.tap(find.byIcon(Icons.arrow_back));
        await pump(tester);
        expect(router.routeInformationProvider.value.uri.path, AppRoutes.MENU);
        expect(prefs.getString(CommonKeys.USER_NAME), 'keep user');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  testWidgets('主题更新保留密码输入、登录态与路由实例', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = container.read(appRouterProvider);
    router.go(AppRoutes.MENU_PASSWORD);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await pump(tester);
    final input = find.byType(EditableText).first;
    await tester.enterText(input, 'preserved');
    final fieldState = tester.state(input);
    for (final mode in ThemeMode.values) {
      await container.read(themeModeProvider.notifier).setThemeMode(mode);
      await pump(tester);
      expect(tester.state(input), same(fieldState));
      expect(tester.widget<EditableText>(input).controller.text, 'preserved');
      expect(container.read(appRouterProvider), same(router));
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.MENU_PASSWORD,
      );
      expect(container.read(storageServiceProvider).isLoginSuccess, isTrue);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
