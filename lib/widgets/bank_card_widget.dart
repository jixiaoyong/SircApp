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
  String cardNumber;
  final String bankName;
  final String ownerName;
  final String expirationDate;
  final String? cardType;
  final double? height;
  final double? width;

  final isMasterCard = MockUtils.random.nextBool();

  BankCardWidget(
      {required this.bankName,
      required this.cardNumber,
      required this.ownerName,
      required this.expirationDate,
      this.cardType,
      this.height,
      this.width}) {
    // format card number
    cardNumber = cardNumber.replaceAll(' ', '').trim();
    // insert space in card number every 4 characters
    cardNumber = cardNumber.replaceAllMapped(RegExp(r'([\s\S]{4})'), (match) {
      return '${match.group(1)} ';
    });
  }

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
          child: Stack(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  bankName,
                  style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontStyle: FontStyle.italic),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1.dp, bottom: 4.dp),
                  child: Image.asset(
                    A.assets_imgs_bank_chip,
                    height: 45.dp,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.dp, bottom: 8.dp),
                  child: Text(
                    cardNumber,
                    style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.5),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.dp, top: 3.dp),
                  child: Text(
                    ownerName,
                    style: TextStyle(
                        fontSize: 15.sp, color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.dp, top: 3.dp),
                  child: Text(
                    expirationDate,
                    style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
              Positioned(
                right: 0,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      cardType ?? (isMasterCard ? "MasterCard".tr : "Visa".tr),
                      style: TextStyle(fontSize: 20.sp, color: Colors.white),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
