import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sirc/core/localization/app_locale.dart';
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
  final String? cardType;
  final double? height;
  final double? width;

  final isMasterCard = MockUtils.random.nextBool();

  BankCardWidget({
    super.key,
    required this.bankName,
    required String cardNumber,
    required this.ownerName,
    required this.expirationDate,
    this.cardType,
    this.height,
    this.width,
  }) : cardNumber = _formatCardNumber(cardNumber);

  static String _formatCardNumber(String raw) {
    final clean = raw.replaceAll(' ', '').trim();
    return clean.replaceAllMapped(RegExp(r'([\s\S]{4})'), (match) {
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
          padding: EdgeInsets.symmetric(horizontal: 14.dp, vertical: 12.dp),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 2.dp),
              borderRadius: BorderRadius.circular(20.dp)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bankName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontStyle: FontStyle.italic),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.dp),
                child: Image.asset(
                  A.assets_imgs_bank_chip,
                  height: 32.dp,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.dp),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    cardNumber,
                    style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 1.5),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.dp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              ownerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                          ),
                          SizedBox(width: 12.dp),
                          Text(
                            expirationDate,
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.dp),
                    Text(
                      cardType ?? (isMasterCard ? "MasterCard".tr : "Visa".tr),
                      style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
