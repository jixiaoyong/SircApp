import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/routes/adaptive_detail_page.dart';

void main() {
  testWidgets('公开入口按窗口断点选 Page，并仅允许同 key 自适应 Page 更新', (tester) async {
    late BuildContext pageContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            pageContext = context;
            return const SizedBox();
          },
        ),
      ),
    );
    Page<void> page({LocalKey key = const ValueKey('detail')}) =>
        createAdaptiveDetailPage(
          context: pageContext,
          key: key,
          child: const SizedBox(),
        );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(839, 800);
    await tester.pump();
    final narrow = page();
    tester.view.physicalSize = const Size(840, 800);
    await tester.pump();
    final wide = page();
    expect(narrow, isA<MaterialPage<void>>());
    expect(wide, isA<NoTransitionPage<void>>());
    expect(narrow.canUpdate(wide), isTrue);
    expect(wide.canUpdate(narrow), isTrue);
    expect(wide.canUpdate(page(key: const ValueKey('other'))), isFalse);
    expect(
      narrow.canUpdate(
        const MaterialPage<void>(key: ValueKey('detail'), child: SizedBox()),
      ),
      isFalse,
    );
  });

  testWidgets('跨断点复用 Route，读取最新 child 并动态更新转场时长', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var label = 'first';
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Navigator(
              pages: [
                const MaterialPage<void>(
                  key: ValueKey('root'),
                  child: SizedBox(),
                ),
                createAdaptiveDetailPage(
                  context: context,
                  key: const ValueKey('detail'),
                  child: Scaffold(body: Text(label)),
                ),
              ],
              onDidRemovePage: (_) {},
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final route = ModalRoute.of(tester.element(find.text('first')))!;
    final narrowDuration = route.transitionDuration;
    expect(narrowDuration, isNot(Duration.zero));
    tester.view.physicalSize = const Size(840, 800);
    rebuild(() => label = 'second');
    await tester.pumpAndSettle();
    expect(find.text('first'), findsNothing);
    expect(ModalRoute.of(tester.element(find.text('second'))), same(route));
    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
    tester.view.physicalSize = const Size(390, 800);
    rebuild(() => label = 'third');
    await tester.pumpAndSettle();
    expect(find.text('second'), findsNothing);
    expect(ModalRoute.of(tester.element(find.text('third'))), same(route));
    expect(route.transitionDuration, narrowDuration);
    expect(route.reverseTransitionDuration, narrowDuration);
  });

  testWidgets('iOS平台边缘拖动完成与取消，取消后页面仍可交互并支持连续返回', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final previousReflectsUrl = GoRouter.optionURLReflectsImperativeAPIs;
    GoRouter.optionURLReflectsImperativeAPIs = true;
    addTearDown(
      () => GoRouter.optionURLReflectsImperativeAPIs = previousReflectsUrl,
    );
    var count = 0;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/detail'),
              child: const Text('open'),
            ),
          ),
          routes: [
            GoRoute(
              path: 'detail',
              pageBuilder: (context, state) => createAdaptiveDetailPage(
                context: context,
                key: state.pageKey,
                child: Scaffold(
                  body: StatefulBuilder(
                    builder: (context, setState) => TextButton(
                      onPressed: () => setState(() => count++),
                      child: Text('count $count'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(platform: TargetPlatform.iOS),
        routerConfig: router,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/detail');
    final detailRoute = ModalRoute.of(tester.element(find.text('count 0')))!;
    final gesture = await tester.startGesture(const Offset(1, 400));
    await gesture.moveBy(const Offset(150, 0));
    await tester.pump();
    expect(detailRoute.popGestureInProgress, isTrue);
    expect(detailRoute.animation!.value, lessThan(1));
    await gesture.moveBy(const Offset(-130, 0));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/detail');
    await tester.tap(find.text('count 0'));
    await tester.pump();
    expect(find.text('count 1'), findsOneWidget);
    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.dragFrom(const Offset(1, 400), const Offset(350, 0));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(find.text('open'), findsOneWidget);
      if (attempt == 0) {
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
      }
    }
    expect(tester.takeException(), isNull);
  });
}
