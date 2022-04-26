import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/*
* @description: an indicator that rotates infinitely
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/25
*/
class EndlessRotatingIndicator extends StatefulWidget {
  final Size size;
  final Widget child;
  final Duration duration;

  const EndlessRotatingIndicator(
      {Key? key,
      required this.child,
      this.size = const Size(50, 50),
      this.duration = const Duration(seconds: 1)})
      : super(key: key);

  @override
  State<EndlessRotatingIndicator> createState() =>
      _EndlessRotatingIndicatorState();
}

class _EndlessRotatingIndicatorState extends State<EndlessRotatingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _controller.value * 2 * math.pi,
      child: SizedBox(
        height: widget.size.height,
        width: widget.size.width,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
