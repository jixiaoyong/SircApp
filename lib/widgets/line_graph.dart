import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart';

/// A date remains in the domain even when its future amount is unavailable.
class ChartDataPoint {
  final String label;
  final String description;
  final double? value;
  const ChartDataPoint(this.label, this.description, this.value);
}

class AmountAxis {
  final double step;
  final double maximum;
  const AmountAxis(this.step, this.maximum);
  factory AmountAxis.forValues(Iterable<double?> values) {
    final peak = values
        .whereType<double>()
        .where((v) => v.isFinite)
        .fold<double>(0, math.max);
    if (peak <= 0) return const AmountAxis(25, 100);
    final raw = peak * 1.1 / 4;
    final magnitude = math
        .pow(10, (math.log(raw) / math.ln10).floor())
        .toDouble();
    final unit = raw / magnitude;
    final nice = [1.0, 2.0, 2.5, 5.0, 10.0].firstWhere((n) => n >= unit);
    final step = nice * magnitude;
    return AmountAxis(step, (peak * 1.1 / step).ceil() * step);
  }
  List<double> get ticks =>
      List.generate((maximum / step).round() + 1, (i) => i * step);
  static String label(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}m';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2);
  }
}

class LineGraph extends StatefulWidget {
  final List<ChartDataPoint> data;
  final bool monthly;
  final String axisLabel;
  final String futureLabel;
  const LineGraph({
    super.key,
    required this.data,
    this.monthly = false,
    required this.axisLabel,
    required this.futureLabel,
  });
  @override
  State<LineGraph> createState() => _LineGraphState();
}

class _LineGraphState extends State<LineGraph> {
  int? selected;
  @override
  void didUpdateWidget(covariant LineGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.monthly != widget.monthly ||
        oldWidget.data.length != widget.data.length ||
        (oldWidget.data.isNotEmpty &&
            widget.data.isNotEmpty &&
            oldWidget.data.first.description !=
                widget.data.first.description)) {
      selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final scale = MediaQuery.textScalerOf(context);
    final axis = AmountAxis.forValues(widget.data.map((p) => p.value));
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = LinerGraphPainter(
          widget.data,
          axis: axis,
          monthly: widget.monthly,
          selected: selected,
          textScaler: scale,
          lineColor: colors.tertiary,
          labelColor: colors.onSurfaceVariant,
          axisColor: colors.outline,
        );
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final plot = painter.plotRect(size);
        void select(Offset point) {
          if (widget.data.isEmpty || plot.width <= 0) return;
          final index =
              ((point.dx - plot.left) / plot.width * (widget.data.length - 1))
                  .round()
                  .clamp(0, widget.data.length - 1);
          setState(() => selected = index);
        }

        final point = selected == null || selected! >= widget.data.length
            ? null
            : widget.data[selected!];
        return Semantics(
          label: widget.axisLabel,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => select(details.localPosition),
                  onHorizontalDragUpdate: (details) =>
                      select(details.localPosition),
                  child: CustomPaint(
                    painter: painter,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              if (point != null)
                Positioned(
                  top: 0,
                  left: plot.left,
                  right: 0,
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        key: const ValueKey('chart-tooltip'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Text(
                          '${point.description}\n${point.value == null ? widget.futureLabel : '\$${point.value!.toStringAsFixed(2)}'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.tertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class LinerGraphPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final AmountAxis axis;
  final bool monthly;
  final int? selected;
  final TextScaler textScaler;
  final Color lineColor, labelColor, axisColor;
  LinerGraphPainter(
    this.data, {
    required this.axis,
    required this.monthly,
    required this.selected,
    required this.textScaler,
    required this.lineColor,
    required this.labelColor,
    required this.axisColor,
  });

  TextPainter text(String value) => TextPainter(
    text: TextSpan(
      text: value,
      style: TextStyle(
        color: labelColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
  )..layout();
  Rect plotRect(Size size) {
    final width = axis.ticks
        .map((v) => text(AmountAxis.label(v)).width)
        .fold<double>(0, math.max);
    return Rect.fromLTRB(
      math.min(width + 12, size.width * .45),
      22,
      math.max(width + 13, size.width - 12),
      math.max(23, size.height - text('0').height - 16),
    );
  }

  /// Label thinning does not remove or resample any data point.
  List<int> labelIndices(Size size) {
    if (data.isEmpty) return [];
    final rect = plotRect(size);
    final labelWidth =
        data.map((p) => text(p.label).width).fold<double>(0, math.max) + 10;
    final capacity = math.max(2, (rect.width / labelWidth).floor() + 1);
    if (capacity >= data.length) return List.generate(data.length, (i) => i);
    if (monthly) {
      final candidates = capacity >= 7
          ? [0, 4, 9, 14, 19, 24, data.length - 1]
          : capacity >= 3
          ? [0, 14, data.length - 1]
          : [0, data.length - 1];
      final result = <int>[0];
      final minGap = labelWidth / rect.width * (data.length - 1);
      for (final index in candidates.skip(1)) {
        if (index < data.length - 1 &&
            index - result.last >= minGap &&
            data.length - 1 - index >= minGap) {
          result.add(index);
        }
      }
      result.add(data.length - 1);
      return result;
    }
    final stride = ((data.length - 1) / (capacity - 1)).ceil();
    return {
      0,
      for (var i = stride; i < data.length - 1; i += stride) i,
      data.length - 1,
    }.toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= 0) return;
    final rect = plotRect(size);
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    canvas.drawLine(rect.topLeft, rect.bottomLeft, axisPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomRight, axisPaint);
    for (final tick in axis.ticks) {
      final y = rect.bottom - tick / axis.maximum * rect.height;
      canvas.drawLine(
        Offset(rect.left - 4, y),
        Offset(rect.left, y),
        axisPaint,
      );
      final label = text(AmountAxis.label(tick));
      label.paint(
        canvas,
        Offset(rect.left - label.width - 8, y - label.height / 2),
      );
    }
    double xFor(int i) =>
        rect.left + rect.width * i / math.max(1, data.length - 1);
    for (final i in labelIndices(size)) {
      final x = xFor(i);
      canvas.drawLine(
        Offset(x, rect.bottom),
        Offset(x, rect.bottom + 4),
        axisPaint,
      );
      final label = text(data[i].label);
      label.paint(
        canvas,
        Offset(
          (x - label.width / 2).clamp(0, math.max(0, size.width - label.width)),
          rect.bottom + 9,
        ),
      );
    }
    canvas.save();
    canvas.clipRect(rect.inflate(3));
    final path = Path();
    Offset? last;
    for (var i = 0; i < data.length; i++) {
      final value = data[i].value;
      if (value == null || !value.isFinite) {
        last = null;
        continue;
      }
      final point = Offset(
        xFor(i),
        rect.bottom - value / axis.maximum * rect.height,
      );
      if (last == null) {
        path.moveTo(point.dx, point.dy);
        canvas.drawCircle(point, 1, Paint()..color = lineColor);
      } else {
        final middle = (last.dx + point.dx) / 2;
        path.cubicTo(middle, last.dy, middle, point.dy, point.dx, point.dy);
      }
      if (selected == i) {
        canvas.drawCircle(point, 5, Paint()..color = lineColor);
      }
      last = point;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder => (size) {
    final rect = plotRect(size);
    return [
      CustomPainterSemantics(
        rect: Rect.fromLTWH(0, rect.top, rect.left, rect.height),
        properties: SemanticsProperties(
          label: axis.ticks.map(AmountAxis.label).join(', '),
          textDirection: TextDirection.ltr,
        ),
      ),
      for (var i = 0; i < data.length; i++)
        CustomPainterSemantics(
          rect: Rect.fromLTWH(
            rect.left + rect.width * i / data.length,
            rect.top,
            rect.width / data.length,
            rect.height,
          ),
          properties: SemanticsProperties(
            label: data[i].description,
            value: data[i].value == null
                ? null
                : '\$${data[i].value!.toStringAsFixed(2)}',
            textDirection: TextDirection.ltr,
          ),
        ),
    ];
  };
  @override
  bool shouldRebuildSemantics(covariant LinerGraphPainter oldDelegate) => true;
  @override
  bool shouldRepaint(covariant LinerGraphPainter oldDelegate) => true;
}
