import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/widgets/constrained_content.dart';

void main() {
  const contentKey = Key('content');

  Widget host({
    required double parentWidth,
    double maxWidth = 360,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    AlignmentGeometry alignment = Alignment.topCenter,
    Widget child = const SizedBox(key: contentKey, height: 48),
  }) {
    return MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: parentWidth,
          child: ConstrainedContent(
            maxWidth: maxWidth,
            padding: padding,
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );
  }

  for (final width in [320.0, 375.0, 430.0, 1461.0]) {
    testWidgets('父宽 $width 时占满可用宽度直到上限且保持内容高度', (tester) async {
      tester.view.physicalSize = const Size(1461, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(host(parentWidth: width));

      final rect = tester.getRect(find.byKey(contentKey));
      expect(rect.width, width.clamp(0, 360));
      expect(rect.height, 48);
      expect(rect.top, 0);
      expect(rect.center.dx, width / 2);
      expect(tester.getSize(find.byType(ConstrainedContent)), Size(width, 48));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('宽视口中的窄分栏依赖父约束且不改 MediaQuery', (tester) async {
    tester.view.physicalSize = const Size(1461, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Size? mediaSize;

    await tester.pumpWidget(
      host(
        parentWidth: 320,
        maxWidth: 520,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Builder(
          builder: (context) {
            mediaSize = MediaQuery.sizeOf(context);
            return const SizedBox(key: contentKey, height: 48);
          },
        ),
      ),
    );

    expect(tester.getSize(find.byKey(contentKey)), const Size(288, 48));
    expect(tester.getRect(find.byKey(contentKey)).left, 16);
    expect(mediaSize, const Size(1461, 900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('maxWidth 包含 padding 且只扣除一次', (tester) async {
    await tester.pumpWidget(
      host(
        parentWidth: 700,
        maxWidth: 520,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      ),
    );

    final rect = tester.getRect(find.byKey(contentKey));
    expect(rect.size, const Size(488, 48));
    expect(rect.left, 106);
    expect(rect.top, 8);
    expect(
      tester.getSize(find.byType(ConstrainedContent)),
      const Size(700, 68),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('父宽动态变化会重新计算内容宽度', (tester) async {
    final width = ValueNotifier(320.0);
    addTearDown(width.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder<double>(
        valueListenable: width,
        builder: (context, value, child) => host(parentWidth: value),
      ),
    );
    expect(tester.getSize(find.byKey(contentKey)).width, 320);

    width.value = 700;
    await tester.pump();
    expect(tester.getSize(find.byKey(contentKey)).width, 360);
    expect(tester.getRect(find.byKey(contentKey)).center.dx, 350);

    width.value = 280;
    await tester.pump();
    expect(tester.getSize(find.byKey(contentKey)).width, 280);
    expect(tester.takeException(), isNull);
  });

  testWidgets('横向无界父级使用 maxWidth 而不是无限宽度', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedContent(
            maxWidth: 360,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(key: contentKey, height: 48),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(contentKey)), const Size(328, 48));
    expect(tester.getSize(find.byType(ConstrainedContent)).width, 360);
    expect(tester.takeException(), isNull);
  });

  testWidgets('可指定水平对齐而不撑满纵轴', (tester) async {
    await tester.pumpWidget(
      host(parentWidth: 700, alignment: Alignment.topRight),
    );
    expect(tester.getRect(find.byKey(contentKey)).right, 700);
    expect(tester.getSize(find.byType(ConstrainedContent)).height, 48);
    expect(tester.takeException(), isNull);
  });
}
