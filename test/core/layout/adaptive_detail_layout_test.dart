import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/layout/adaptive_detail_layout.dart';

void main() {
  for (final width in [839.0, 840.0]) {
    for (final keepPrimaryMounted in [false, true]) {
      for (final hasDetail in [false, true]) {
        testWidgets('窗口 $width，保留来源 $keepPrimaryMounted，有详情 $hasDetail', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 600);
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            MaterialApp(
              home: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 320,
                  height: 500,
                  child: AdaptiveDetailLayout(
                    hasDetail: hasDetail,
                    keepPrimaryMounted: keepPrimaryMounted,
                    primary: const SizedBox.expand(key: ValueKey('primary')),
                    detail: const SizedBox.expand(key: ValueKey('detail')),
                  ),
                ),
              ),
            ),
          );
          final isWide = width >= 840;
          final directDetail = !isWide && !keepPrimaryMounted;
          final showPrimary = !directDetail && (isWide || !hasDetail);
          expect(
            find.byKey(const ValueKey('primary')),
            showPrimary ? findsOneWidget : findsNothing,
          );
          expect(
            find.byKey(const ValueKey('primary'), skipOffstage: false),
            directDetail ? findsNothing : findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('detail')),
            directDetail || hasDetail ? findsOneWidget : findsNothing,
          );
          expect(
            find.byKey(const ValueKey('detail'), skipOffstage: false),
            findsOneWidget,
          );
          if (showPrimary) {
            expect(
              tester.getSize(find.byKey(const ValueKey('duo-pane'))).width,
              isWide && hasDetail ? 159.5 : 320,
            );
          }
          if (directDetail || hasDetail) {
            expect(
              tester.getSize(find.byKey(const ValueKey('detail'))).width,
              isWide && hasDetail ? 159.5 : 320,
            );
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
