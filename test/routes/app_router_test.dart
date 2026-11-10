import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/auth/data/auth_repository.dart';
import 'package:sirc/features/settings/presentation/not_found_page.dart';
import 'package:sirc/routes/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> createContainer({bool loggedIn = false}) async {
    SharedPreferences.setMockInitialValues({
      CommonKeys.IS_LOGIN_SUCCESS: loggedIn,
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
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    for (final path in ['/menu/add-card', '/menu/password']) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/sign_in');
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
        child: MaterialApp.router(routerConfig: router),
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
        find.text('JI,XIAOYONG'),
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
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/sign_in');
  });
}
