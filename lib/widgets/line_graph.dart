import 'package:flutter/material.dart';
import 'package:sirc/utils/size_extension.dart';

/// Dart 3 原生 Record 类型的图表数据点 (label, value)
typedef ChartDataPoint = (String label, double value);

/*
* @description: 曲线图
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class LineGraph extends StatefulWidget {
  /// data: [{time : percentage}]
  /// time may be one day or one month
  /// percentage change which value in 0~1
  final List<ChartDataPoint> data;

  const LineGraph({super.key, required this.data});

  @override
  State<LineGraph> createState() => _LineGraphState();
}

class _LineGraphState extends State<LineGraph> {
  Offset? _currentPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _currentPosition = details.localPosition;
        });
      },
      child: CustomPaint(
        painter: LinerGraphPainter(
          widget.data,
          _currentPosition,
          lineColor: Theme.of(context).colorScheme.tertiary,
          labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          axisColor: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

class LinerGraphPainter extends CustomPainter {
  static final double _lineWidth = 2.0.dp;
  static double _maxPercentage = 1.0;
  static double _minPercentage = 0.0;

  List<ChartDataPoint> data;
  Offset? currentPosition;

  final Color lineColor;
  final Color labelColor;
  final Color axisColor;

  LinerGraphPainter(
    this.data,
    this.currentPosition, {
    this.lineColor = const Color(0xFF526F91),
    this.labelColor = const Color(0xFF66686C),
    this.axisColor = const Color(0xFF85888D),
  }) {
    var tempPercentage = data.map((e) => e.$2).toList();
    tempPercentage.sort();
    _maxPercentage = tempPercentage.isEmpty ? 1 : tempPercentage.last;
    _minPercentage = tempPercentage.isEmpty ? 0 : tempPercentage.first;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double width = size.width;
    final double height = size.height;

    final double bottomAxisXFFontHeight = 0.2 * height;
    final availableHeight = height - bottomAxisXFFontHeight;

    final double percentageCount = (_maxPercentage - _minPercentage) * 10 + 1;
    final double axisYStep = availableHeight / percentageCount;
    final double axisXStep = width / (data.length > 1 ? data.length - 1 : 1);

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = _lineWidth
      ..style = PaintingStyle.stroke;

    final textPaint = TextPainter()..textDirection = TextDirection.ltr;

    final circlePaint = Paint()
      ..color = lineColor
      ..strokeWidth = _lineWidth
      ..style = PaintingStyle.fill;

    // draw the percentage line
    final path = Path();
    var lastPoint = Offset(0, availableHeight);
    for (var i = 0; i < data.length; i++) {
      final (label, percentage) = data[i];
      final x = axisXStep * i;
      final y = availableHeight - percentage * axisYStep * 10;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        var controlPoint1X = (lastPoint.dx + x) / 2;
        var controlPoint1Y = lastPoint.dy;

        var controlPoint2X = (lastPoint.dx + x) / 2;
        var controlPoint2Y = y;
        path.cubicTo(
          controlPoint1X,
          controlPoint1Y,
          controlPoint2X,
          controlPoint2Y,
          x,
          y,
        );
      }
      lastPoint = Offset(x, y);

      // draw data text
      var text = TextSpan(
        text: label,
        style: TextStyle(
          color: labelColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      );
      textPaint.text = text;
      textPaint.layout();
      textPaint.paint(
        canvas,
        Offset(x - textPaint.width / 2, availableHeight + textPaint.height),
      );

      // draw the current tap position
      if (currentPosition != null &&
          currentPosition!.dx >= x - axisXStep / 2 &&
          currentPosition!.dx <= x + axisXStep / 2) {
        canvas.drawCircle(Offset(x, y), 5.dp, circlePaint);

        // draw the percentage text
        var percentageText = TextSpan(
          text: '${(percentage * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            color: lineColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        );
        textPaint.text = percentageText;
        textPaint.layout();
        var textY = y + textPaint.height + 10.dp;
        if (textY > availableHeight) {
          textY = y - textPaint.height - 10.dp;
        }
        textPaint.paint(canvas, Offset(x - textPaint.width / 2, textY));
      }
    }
    canvas.drawPath(path, paint);

    // draw the day line
    paint
      ..color = axisColor
      ..strokeWidth = 1.dp;
    canvas.drawLine(
      Offset(0, availableHeight),
      Offset(width, availableHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant LinerGraphPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.currentPosition != currentPosition ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.labelColor != labelColor ||
      oldDelegate.axisColor != axisColor;
}
