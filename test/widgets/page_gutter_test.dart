import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/widgets/page_gutter.dart';

void main() {
  const key = Key('child');

  Widget host({required double parentWidth, double? maxWidth}) => MaterialApp(
    home: Center(
      child: SizedBox(
        width: parentWidth,
        child: PageGutter(
          maxWidth: maxWidth,
          child: const SizedBox(key: key, height: 20),
        ),
      ),
    ),
  );

  testWidgets('gutter follows local width and caps at 32', (tester) async {
    for (final (width, expected) in [
      (320.0, 16.0),
      (400.0, 21.33),
      (560.0, 32.0),
    ]) {
      await tester.pumpWidget(host(parentWidth: width));
      final rect = tester.getRect(find.byKey(key));
      expect(rect.width, closeTo(width - expected * 2, 2));
      expect(rect.center.dx, 400);
    }

    // A locally supplied width above the interpolation cap exercises the maximum.
    await tester.pumpWidget(host(parentWidth: 760));
    final rect = tester.getRect(find.byKey(key));
    expect(rect.width, 696);
    expect(rect.center.dx, 400);
  });

  testWidgets('uses received local parent width, not viewport width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(parentWidth: 400));
    final rect = tester.getRect(find.byKey(key));
    expect(rect.width, closeTo(357.33, 1));
    expect(rect.center.dx, 600);
  });

  testWidgets('maxWidth centers outer frame and includes gutter', (
    tester,
  ) async {
    await tester.pumpWidget(host(parentWidth: 800, maxWidth: 520));
    final rect = tester.getRect(find.byKey(key));
    expect(rect.width, 456);
    expect(rect.left, 172);
    expect(rect.right, 628);
  });

  testWidgets('maxWidth frame shrinks to narrow parent', (tester) async {
    await tester.pumpWidget(host(parentWidth: 300, maxWidth: 520));
    final rect = tester.getRect(find.byKey(key));
    expect(rect.width, 268);
    expect(rect.left, 266);
  });
}
