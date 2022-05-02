import 'package:flutter/material.dart';
import 'package:sirc/utils/size_extension.dart';

class FootlightsForBankCard extends StatefulWidget {
  final double? screenWidth;

  const FootlightsForBankCard({Key? key, this.screenWidth}) : super(key: key);

  @override
  State<FootlightsForBankCard> createState() => _FootlightsForBankCardState();
}

class _FootlightsForBankCardState extends State<FootlightsForBankCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _percentage = 0.0;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
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
    var backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    final double width =
        widget.screenWidth ?? MediaQuery.of(context).size.width;
    final double smallBallSize = width * (0.15 + 0.1 * _percentage);
    final double bigBallSize = width * (0.5 - 0.2 * _percentage);

    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          backgroundColor.withOpacity(0.35),
          Colors.grey.shade400.withOpacity(0.2),
          Colors.grey.shade400.withOpacity(0.5),
          Colors.grey.shade400.withOpacity(0.2),
          backgroundColor.withOpacity(0.35),
          backgroundColor,
        ],
        stops: const [0.0, 0.4, 0.8, 0.85, 0.95, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )),
      child: Stack(
        children: [
          Positioned(
            right: (90 * _percentage - 50).dp,
            top: 20.dp,
            child: Container(
              height: bigBallSize,
              width: bigBallSize,
              decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [
                    Colors.orangeAccent.withOpacity(0.2),
                    Colors.orangeAccent.withOpacity(0.9)
                  ]),
                  borderRadius: BorderRadius.circular(100.dp)),
            ),
          ),
          Positioned(
            left: (50 * _percentage - 30).dp,
            bottom: (15 * _percentage + 5).dp,
            child: Container(
              height: smallBallSize,
              width: smallBallSize,
              decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [
                    Colors.purple.withOpacity(0.2),
                    Colors.purple.withOpacity(0.9)
                  ]),
                  borderRadius: BorderRadius.circular(100.dp)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
