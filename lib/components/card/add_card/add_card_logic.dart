import 'package:flutter/src/gestures/drag_details.dart';
import 'package:get/get.dart';
import 'package:sirc/components/main_app_logic.dart';

import 'add_card_state.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/21
*/
class AddCardLogic extends GetxController {
  final MainAppLogic _mainAppLogic = Get.find();

  final AddCardState state = AddCardState();

  @override
  void onInit() {
    state.ownerName.value = _mainAppLogic.userName.value;
    super.onInit();
  }

  void onBankCardPanUpdate(DragUpdateDetails? details) {
    if (details == null) {
      state.cardRotateAngle.value = AddCardState.CARD_MIN_ROTATE_ANGLE;
      return;
    }

    var dy = details.delta.dy;

    // scroll direction is vertical, so we rotate the card
    final dragOffsetPercent = -dy / AddCardState.CARD_MAX_DRAG_OFFSET;
    var angle = dragOffsetPercent * AddCardState.CARD_MAX_ROTATE_ANGLE +
        state.cardRotateAngle.value;

    if (angle > AddCardState.CARD_MAX_ROTATE_ANGLE) {
      angle = AddCardState.CARD_MAX_ROTATE_ANGLE;
    } else if (angle < -AddCardState.CARD_MAX_ROTATE_ANGLE) {
      angle = -AddCardState.CARD_MAX_ROTATE_ANGLE;
    }

    state.cardRotateAngle.value = angle;
  }

  void setOwnerName(String value) {
    state.ownerName.value = value;
    if (value.isEmpty) {
      state.ownerNameError.value = 'Please type in your name';
    } else {
      state.ownerNameError.value = null;
    }
  }

  void setCardNumber(String value) {
    state.cardNumber.value = value;
    if (value.isEmpty) {
      state.cardNumberError.value = 'Please enter bank card number';
    } else {
      state.cardNumberError.value = null;
    }
  }

  void setExpireDate(String value) {
    // add / to the second character of value
    state.expireDate.value = value.substring(0, 2) + '/' + value.substring(2);
    // state.expireDate.value = value;
    if (value.isEmpty) {
      state.expireDateError.value = 'Please enter an expiration date';
    } else {
      state.expireDateError.value = null;
    }
  }

  void setCvv(String value) {
    state.cvv.value = value;
    if (value.isEmpty) {
      state.cvvError.value = 'Please enter CVV';
    } else {
      state.cvvError.value = null;
    }
  }

  void addCard() {}

  isUserInputValid() {
    return state.ownerNameError.value == null &&
        state.cardNumberError.value == null &&
        state.expireDateError.value == null &&
        state.cvvError.value == null;
  }
}
