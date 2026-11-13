import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class FootlightsForBankCard extends StatefulWidget {
  final double? screenWidth;

  const FootlightsForBankCard({super.key, this.screenWidth});

  @override
  State<FootlightsForBankCard> createState() => _FootlightsForBankCardState();
}

class _FootlightsForBankCardState extends State<FootlightsForBankCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _percentage = 0.0;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _controller.addListener(() {
      setState(() {
        _percentage = _controller.value;
      });
    });
    _controller.repeat(reverse: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // A deliberately light exhibition island in both themes. The muted backing
    // keeps the untouched translucent card's white lettering readable.
    const backgroundColor = Color(0xFFF2F0EE);

    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor,
            Color(0xFFA783A3),
            Color(0xFFA18B94),
            Color(0xFFA18B94),
            backgroundColor,
            backgroundColor,
          ],
          stops: [0.0, 0.4, 0.8, 0.85, 0.95, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 按最大动画尺寸预留竖向偏移，避免宽窗口下球体被上下裁切。
          final width = math.min(
            widget.screenWidth ?? constraints.maxWidth,
            math.min(
              constraints.maxWidth,
              math.max(0.0, constraints.maxHeight - 20) * 2,
            ),
          );
          final smallBallSize = width * (0.15 + 0.1 * _percentage);
          final bigBallSize = width * (0.5 - 0.2 * _percentage);

          return Stack(
            children: [
              Positioned(
                right: (90 * _percentage - 50),
                top: 20,
                child: Container(
                  height: bigBallSize,
                  width: bigBallSize,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.orangeAccent.withValues(alpha: 0.2),
                        Colors.orangeAccent.withValues(alpha: 0.9),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: (50 * _percentage - 30),
                bottom: (15 * _percentage + 5),
                child: Container(
                  height: smallBallSize,
                  width: smallBallSize,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.purple.withValues(alpha: 0.2),
                        Colors.purple.withValues(alpha: 0.9),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
