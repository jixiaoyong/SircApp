import 'package:flutter/material.dart';
import 'package:sirc/utils/size_extension.dart';

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
  final List<Pair<String, double>> data;

  const LineGraph({Key? key, required this.data}) : super(key: key);

  @override
  State<LineGraph> createState() => _LineGraphState();
}

class _LineGraphState extends State<LineGraph> {
  Offset? _currentPosition = null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _currentPosition = details.localPosition;
        });
      },
      child: CustomPaint(
        painter: LinerGraphPainter(widget.data, _currentPosition),
      ),
    );
  }
}

class LinerGraphPainter extends CustomPainter {
  static double _lineWidth = 2.0.dp;
  static double _maxPercentage = 1.0;
  static double _minPercentage = 0.0;

  List<Pair<String, double>> data;
  Offset? currentPosition;

  LinerGraphPainter(this.data, this.currentPosition) {
    var tempPercentage = data.map((e) => e.second).toList();
    tempPercentage.sort();
    _maxPercentage = tempPercentage.last;
    _minPercentage = tempPercentage.first;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final double _bottomAxisXFFontHeight = 0.2 * height;
    final availableHeight = height - _bottomAxisXFFontHeight;

    final double percentageCount = (_maxPercentage - _minPercentage) * 10 + 1;
    final double _axisYStep = availableHeight / percentageCount;
    final double _axisXStep = width / (data.length - 1);

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = _lineWidth
      ..style = PaintingStyle.stroke;

    final textPaint = TextPainter()..textDirection = TextDirection.ltr;

    final circlePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = _lineWidth
      ..style = PaintingStyle.fill;

    // draw the percentage line
    final path = Path();
    var lastPoint = Offset(0, availableHeight);
    for (var i = 0; i < data.length; i++) {
      final x = _axisXStep * i;
      final y = availableHeight - data[i].second * _axisYStep * 10;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        var controlPoint1X = (lastPoint.dx + x) / 2;
        var controlPoint1Y = lastPoint.dy;

        var controlPoint2X = (lastPoint.dx + x) / 2;
        var controlPoint2Y = y;
        path.cubicTo(controlPoint1X, controlPoint1Y, controlPoint2X,
            controlPoint2Y, x, y);
      }
      lastPoint = Offset(x, y);

      // draw data text
      var text = TextSpan(
          text: data[i].first,
          style: TextStyle(
              color: Colors.black,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold));
      textPaint.text = text;
      textPaint.layout();
      textPaint.paint(canvas,
          Offset(x - textPaint.width / 2, availableHeight + textPaint.height));

      // draw the current tap position
      if (currentPosition != null &&
          currentPosition!.dx >= x - _axisXStep / 2 &&
          currentPosition!.dx <= x + _axisXStep / 2) {
        canvas.drawCircle(Offset(x, y), 5.dp, circlePaint);

        // draw the percentage text
        var percentage = data[i].second;
        var percentageText = TextSpan(
            text: '${(percentage * 100).toStringAsFixed(0)}%',
            style: TextStyle(
                color: Colors.blue,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold));
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
      ..color = Colors.blue.shade200
      ..strokeWidth = 1.dp;
    canvas.drawLine(
        Offset(0, availableHeight), Offset(width, availableHeight), paint);
  }

  @override
  bool shouldRepaint(covariant LinerGraphPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.currentPosition != currentPosition;
}

class Pair<T, U> {
  Pair(this.first, this.second);

  final T first;
  final U second;
}
