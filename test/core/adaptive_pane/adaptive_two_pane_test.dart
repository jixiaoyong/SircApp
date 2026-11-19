import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/adaptive_pane/adaptive_pane.dart';

void main() {
  group('AdaptiveTwoPane Tests', () {
    testWidgets('宽屏下展示双栏并排且 isWide=true, isDuo=true', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool isWideObserved;
      late bool isDuoObserved;
      late AdaptiveDisplayMode modeObserved;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveTwoPane(
              breakpoint: 840,
              primary: Builder(
                builder: (context) {
                  final scope = AdaptivePaneScope.of(context);
                  isWideObserved = scope.isWide;
                  isDuoObserved = scope.isDuo;
                  modeObserved = scope.mode;
                  return const Text('PrimaryContent');
                },
              ),
              detail: const Text('DetailContent'),
            ),
          ),
        ),
      );

      expect(find.text('PrimaryContent'), findsOneWidget);
      expect(find.text('DetailContent'), findsOneWidget);
      expect(isWideObserved, isTrue);
      expect(isDuoObserved, isTrue);
      expect(modeObserved, AdaptiveDisplayMode.dualPane);
    });

    testWidgets('宽屏下无详情时展示占位且 isWide=true, isDuo=false', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool isWideObserved;
      late bool isDuoObserved;
      late AdaptiveDisplayMode modeObserved;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveTwoPane(
              breakpoint: 840,
              primary: Builder(
                builder: (context) {
                  final scope = AdaptivePaneScope.of(context);
                  isWideObserved = scope.isWide;
                  isDuoObserved = scope.isDuo;
                  modeObserved = scope.mode;
                  return const Text('PrimaryContent');
                },
              ),
              detail: null,
              placeholder: const Text('EmptyPlaceholder'),
            ),
          ),
        ),
      );

      expect(find.text('PrimaryContent'), findsOneWidget);
      expect(find.text('EmptyPlaceholder'), findsOneWidget);
      expect(isWideObserved, isTrue);
      expect(isDuoObserved, isFalse);
      expect(modeObserved, AdaptiveDisplayMode.dualPaneEmpty);
    });

    testWidgets('窄屏下仅渲染 Primary 且 isWide=false, isDuo=false', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool isWideObserved;
      late bool isDuoObserved;
      late AdaptiveDisplayMode modeObserved;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveTwoPane(
              breakpoint: 840,
              primary: Builder(
                builder: (context) {
                  final scope = AdaptivePaneScope.of(context);
                  isWideObserved = scope.isWide;
                  isDuoObserved = scope.isDuo;
                  modeObserved = scope.mode;
                  return const Text('NarrowPrimary');
                },
              ),
              detail: const Text('NarrowDetail'),
            ),
          ),
        ),
      );

      expect(find.text('NarrowPrimary'), findsOneWidget);
      expect(find.text('NarrowDetail'), findsNothing);
      expect(isWideObserved, isFalse);
      expect(isDuoObserved, isFalse);
      expect(modeObserved, AdaptiveDisplayMode.singlePane);
    });

    testWidgets('从宽屏拖动拉窄到窄屏时触发路由压栈', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var pushedCount = 0;
      final adapter = DelegateNavigationAdapter(
        onPush: (context, detail) => pushedCount++,
        onPop: (context) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveTwoPane(
              breakpoint: 840,
              navigationAdapter: adapter,
              primary: const Text('Primary'),
              detail: const Text('Detail'),
            ),
          ),
        ),
      );

      expect(pushedCount, 0);

      // 动态将窗口尺寸缩窄到 390
      tester.view.physicalSize = const Size(390, 844);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(pushedCount, 1);
    });

    testWidgets('输入框文本状态通过 GlobalKey 在宽屏下正常操作', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = TextEditingController(text: 'InitialNote');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveTwoPane(
              breakpoint: 840,
              primary: const Text('PrimaryList'),
              detail: Material(
                child: TextField(
                  key: const ValueKey('detail-text-field'),
                  controller: controller,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('InitialNote'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('detail-text-field')),
        'UpdatedNote',
      );
      await tester.pump();
      expect(controller.text, 'UpdatedNote');
    });
  });
}
