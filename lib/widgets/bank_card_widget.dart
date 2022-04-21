import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/gen_a/A.dart';
import 'package:sirc/mock/mock_utils.dart';
import 'package:sirc/utils/size_extension.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
class BankCardWidget extends StatelessWidget {
  final String cardNumber;
  final String bankName;
  final String ownerName;
  final String expirationDate;
  final List<Color> backgroundColors;
  final double? height;
  final double? width;

  BankCardWidget(
      {required this.bankName,
      required this.cardNumber,
      required this.backgroundColors,
      required this.ownerName,
      required this.expirationDate,
      this.height,
      this.width});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.dp),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: height ?? 200.dp,
          width: width,
          padding: EdgeInsets.all(10.dp),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 2.dp),
              borderRadius: BorderRadius.circular(20.dp)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              bankName,
              style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontStyle: FontStyle.italic),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.dp),
              child: Image.asset(
                A.assets_imgs_bank_chip,
                height: 45.dp,
                fit: BoxFit.fitHeight,
              ),
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
                  MockUtils.random.nextBool() ? "MasterCard".tr : "Visa".tr,
                  style: TextStyle(fontSize: 20.sp, color: Colors.white),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
