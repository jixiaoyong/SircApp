import 'package:flutter/material.dart';

/*
* @description: a progress indicator that displays a linear gradient
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/25
*/
class GradientProgressIndicator extends StatelessWidget {
  final double height;
  final double? width;

  // progress, 0.0 - 1.0
  final double progress;

  // gradient colors
  final List<Color> foregroundColors;

  final Color backgroundColor;

  const GradientProgressIndicator(
      {super.key, this.height = 10.0,
      this.width,
      this.progress = 0.0,
      this.foregroundColors = const [Colors.red, Colors.green],
      this.backgroundColor = Colors.grey});

  @override
  Widget build(BuildContext context) {
    final actualWidth = width ?? MediaQuery.of(context).size.width;
    final foregroundWidth = actualWidth * progress;

    return Container(
      height: height,
      width: actualWidth,
      color: backgroundColor,
      child: Container(
        width: foregroundWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: foregroundColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}
