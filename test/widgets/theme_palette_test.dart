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
    final data = [const ChartDataPoint('Mon', 'Monday', 30)];
    LinerGraphPainter painter(Color color) => LinerGraphPainter(
      data,
      axis: AmountAxis.forValues([30]),
      monthly: false,
      selected: null,
      textScaler: TextScaler.noScaling,
      lineColor: color,
      labelColor: Colors.grey,
      axisColor: Colors.grey,
    );
    expect(painter(Colors.red).shouldRepaint(painter(Colors.blue)), isTrue);
  });

  testWidgets('空数据与单点折线安全绘制', (tester) async {
    for (final data in <List<ChartDataPoint>>[
      [],
      [const ChartDataPoint('Mon', 'Monday', 30)],
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Center(
            child: SizedBox(
              width: 300,
              height: 160,
              child: LineGraph(
                data: data,
                axisLabel: 'Volume',
                futureLabel: 'Future',
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
