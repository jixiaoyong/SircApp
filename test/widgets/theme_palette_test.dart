import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/widgets/line_graph.dart';

void main() {
  test('UI 2.0 独立亮暗表面与控制边界', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final c = theme.colorScheme;
      expect(c.surface, isNot(c.surfaceContainerHighest));
      expect(c.primary, isNot(c.secondary));
      expect(c.secondary, isNot(c.tertiary));
      expect(c.outline, isNot(c.outlineVariant));
      final border =
          theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
      expect(border.borderRadius, BorderRadius.circular(14));
      expect(border.borderSide.color, c.outline);
    }
  });

  test('折线图颜色变化必须重绘', () {
    final data = [('Mon', .3), ('Tue', .5)];
    final original = LinerGraphPainter(data, null);
    expect(LinerGraphPainter(data, null).shouldRepaint(original), isFalse);
    expect(
      LinerGraphPainter(
        data,
        null,
        lineColor: Colors.red,
      ).shouldRepaint(original),
      isTrue,
    );
    expect(
      LinerGraphPainter(
        data,
        null,
        labelColor: Colors.white,
      ).shouldRepaint(original),
      isTrue,
    );
    expect(
      LinerGraphPainter(
        data,
        null,
        axisColor: Colors.white,
      ).shouldRepaint(original),
      isTrue,
    );
  });

  testWidgets('空数据与单点折线安全绘制', (tester) async {
    for (final data in <List<ChartDataPoint>>[
      [],
      [('Mon', .3)],
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SizedBox(width: 300, height: 160, child: LineGraph(data: data)),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
