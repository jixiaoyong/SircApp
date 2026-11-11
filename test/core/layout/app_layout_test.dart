import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/layout/app_layout.dart';

void main() {
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
  });
}
