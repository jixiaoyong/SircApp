import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/layout/app_layout.dart';

void main() {
  test('logical width uses the inclusive 840 layout boundary', () {
    expect(AppLayout.isWideWidth(0), isFalse);
    expect(AppLayout.isWideWidth(600), isFalse);
    expect(AppLayout.isWideWidth(839.999), isFalse);
    expect(AppLayout.isWideWidth(840), isTrue);
    expect(AppLayout.isWideWidth(840.001), isTrue);
    expect(AppLayout.isWideWidth(1200), isTrue);
  });

  for (final width in [839.0, 840.0, 841.0]) {
    testWidgets('window width $width uses the application threshold', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      late bool isWide;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isWide = AppLayout.isWideWindow(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(isWide, width >= 840);
    });
  }

  testWidgets('window query ignores a narrower LayoutScope', (tester) async {
    tester.view.physicalSize = const Size(841, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late bool isWide;
    late double containerWidth;
    late bool isWideContainer;
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            height: 500,
            child: LayoutScope(
              child: Builder(
                builder: (context) {
                  isWide = AppLayout.isWideWindow(context);
                  containerWidth = AppLayout.containerQuery(context).width;
                  isWideContainer = AppLayout.isWideWidth(containerWidth);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(isWide, isTrue);
    expect(containerWidth, 320);
    expect(isWideContainer, isFalse);
  });
}
