import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sirc/utils/size_extension.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
class BankCardWidget extends StatelessWidget {
  static var random = Random(DateTime.now().millisecondsSinceEpoch);

  final String cardNumber;
  final String bankName;
  final List<Color> backgroundColors;

  BankCardWidget(
      {required this.bankName,
      required this.cardNumber,
      required this.backgroundColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.dp),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: backgroundColors,
              begin: Alignment.bottomLeft,
              end: Alignment.topRight),
          borderRadius: BorderRadius.circular(20.dp)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          bankName,
          style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic),
        ),
        Expanded(
          child: Center(
            child: Text(
              cardNumber,
              style: TextStyle(fontSize: 20.sp, color: Colors.white),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              random.nextBool() ? "MasterCard" : "Visa",
              style: TextStyle(fontSize: 20.sp, color: Colors.white),
            ),
          ],
        )
      ]),
    );
  }
}
