import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/widgets/jingang_widget.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('金刚位随局部宽度增长且十五项完整 scale=$scale', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 900);
      addTearDown(tester.view.reset);
      var previous = 0;
      for (final width in [320.0, 390.0, 440.0, 490.0, 900.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: width,
                    child: JingangWidget<int>(
                      data: List.generate(15, (i) => i),
                      mainAxisExtent: 80,
                      itemBuilder: (_, index, page, value) => SizedBox(
                        key: ValueKey('item-$value'),
                        height: 44,
                        child: Text('Item $value'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final grid = tester.widget<GridView>(find.byType(GridView).first);
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, greaterThanOrEqualTo(previous));
        expect(width / delegate.crossAxisCount, greaterThanOrEqualTo(44));
        previous = delegate.crossAxisCount;
        // PageStorage 保留当前页；先回到第一页再验证顺序完整性。
        for (var page = 0; page < 8; page++) {
          await tester.drag(find.byType(PageView), Offset(width, 0));
          await tester.pumpAndSettle();
        }
        final seen = <int>{};
        for (var page = 0; page < 8; page++) {
          for (var i = 0; i < 15; i++) {
            if (find.byKey(ValueKey('item-$i')).evaluate().isNotEmpty) {
              seen.add(i);
            }
          }
          await tester.drag(find.byType(PageView), Offset(-width, 0));
          await tester.pumpAndSettle();
        }
        expect(seen, containsAll(List.generate(15, (i) => i)));
        expect(tester.takeException(), isNull);
      }
      expect(previous, greaterThan(scale == 1 ? 9 : 6));
    });
  }
}
