import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';
import 'package:sirc/routes/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> createContainer({bool loggedIn = false}) async {
    SharedPreferences.setMockInitialValues({
      CommonKeys.IS_LOGIN_SUCCESS: loggedIn,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  Future<String> resolve(
    WidgetTester tester,
    GoRouter router,
    String location,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (value) {
      context = value;
      return const SizedBox();
    })));
    router.go(location);
    final matches = await router.routeInformationParser
        .parseRouteInformationWithDependencies(
      router.routeInformationProvider.value,
      context,
    );
    expect(matches.isError, isFalse);
    return matches.uri.toString();
  }

  testWidgets('匿名直接深链访问所有业务路由统一重定向，含查询参数及未知路由', (tester) async {
    final container = await createContainer();
    final router = container.read(appRouterProvider);
    for (final path in [
      '/main',
      '/wallet',
      '/history',
      '/person',
      '/menu',
      '/languages',
      '/notifications',
      '/password',
      '/add_card',
      '/about',
      '/history_details',
      '/main?tab=wallet',
      '/unknown',
      '/sign_in/extra',
      '/sign_up/extra',
    ]) {
      expect(await resolve(tester, router, path), '/sign_in', reason: path);
    }
  });

  testWidgets('匿名精确白名单可访问，注册及找回密码链路不被阻断', (tester) async {
    final container = await createContainer();
    final router = container.read(appRouterProvider);
    for (final path in [
      '/',
      '/sign_in',
      '/sign_up',
      '/forget_pwd',
      '/set_pwd',
      '/set_pwd?username=test',
    ]) {
      expect(await resolve(tester, router, path), path);
    }
  });

  testWidgets('冷启动读取已持久化登录态，不误拦截业务深链', (tester) async {
    final container = await createContainer(loggedIn: true);
    final router = container.read(appRouterProvider);
    for (final path in ['/main', '/wallet', '/password', '/history_details']) {
      expect(await resolve(tester, router, path), path);
    }
  });

  testWidgets('登录成功和退出登录刷新同一个路由实例，登出后深链再次受保护', (tester) async {
    final container = await createContainer();
    final router = container.read(appRouterProvider);
    final repo = container.read(authRepositoryProvider);
    var refreshes = 0;
    void onRefresh() => refreshes++;
    router.routeInformationProvider.addListener(onRefresh);
    addTearDown(
        () => router.routeInformationProvider.removeListener(onRefresh));

    expect(await resolve(tester, router, '/main'), '/sign_in');
    final beforeLogin = refreshes;
    expect(await repo.login('jixiaoyong', '123456', mockDelay: Duration.zero),
        isTrue);
    expect(refreshes, beforeLogin + 1);
    expect(identical(router, container.read(appRouterProvider)), isTrue);
    expect(await resolve(tester, router, '/main'), '/main');

    final beforeLogout = refreshes;
    await repo.logout();
    expect(refreshes, beforeLogout + 1);
    expect(await resolve(tester, router, '/main'), '/sign_in');
    expect(await resolve(tester, router, '/sign_in'), '/sign_in');
  });
}
