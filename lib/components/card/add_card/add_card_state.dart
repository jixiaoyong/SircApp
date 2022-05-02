import 'dart:math' as math;

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:sirc/utils/size_extension.dart';
import 'package:sirc/widgets/bank_card_widget.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class AddCardState {
  static const double CARD_MAX_ROTATE_ANGLE = math.pi / 8;
  static const double CARD_MIN_ROTATE_ANGLE = math.pi / 18;
  static final double CARD_MAX_DRAG_OFFSET = 90.dp;

  static final BankCardWidget defaultCard = BankCardWidget(
    cardNumber: '**** **** **** ****',
    ownerName: 'YOUR NAME',
    expirationDate: '00/00',
    bankName: 'Visa Classic',
    cardType: 'Visa',
  );

  var cardRotateAngle = CARD_MIN_ROTATE_ANGLE.obs;

  Rx<String> ownerName = Rx("");

  // bankName and cardType depend on card number, but we will use default value for test
  Rx<String> bankName = Rx("Visa Classic");
  Rx<String> cardType = Rx("Visa");

  Rx<String> cardNumber = Rx("");
  Rx<String?> expireDateString = Rx(null);
  DateTime? expireDate;
  Rx<String> cvv = Rx("");

  Rx<String?> ownerNameError = Rx(null);
  Rx<String?> cardNumberError = Rx(null);
  Rx<String?> expireDateError = Rx(null);
  Rx<String?> cvvError = Rx("");
}
