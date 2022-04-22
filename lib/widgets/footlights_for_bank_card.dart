import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sirc/utils/size_extension.dart';

class FootlightsForBankCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var backgroundColor = Theme.of(context).scaffoldBackgroundColor;

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
            right: -50.dp,
            top: 20.dp,
            child: Container(
              height: 200.dp,
              width: 200.dp,
              decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [
                    Colors.orangeAccent.withOpacity(0.2),
                    Colors.orangeAccent.withOpacity(0.9)
                  ]),
                  borderRadius: BorderRadius.circular(100.dp)),
            ),
          ),
          Positioned(
            left: 5.dp,
            bottom: 10.dp,
            child: Container(
              height: 150.dp,
              width: 150.dp,
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
}
