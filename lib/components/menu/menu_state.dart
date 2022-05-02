import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/bean/triple.dart';
import 'package:sirc/routes/app_routes.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class MenuState {
  final Rx<List<Triple<IconData, String, String>>> menuItems =
      Rx(generateMenus());

  var isFingerprintOpen = false.obs;

  static List<Triple<IconData, String, String>> generateMenus() => [
        Triple(Icons.language_outlined, "Language".tr, AppRoutes.LANGUAGES),
        Triple(Icons.lock_outlined, "Change Password".tr, AppRoutes.PASSWORD),
        Triple(Icons.fingerprint_outlined, "Fingerprint Login".tr,
            AppRoutes.FINGERPRINT),
        Triple(Icons.credit_card_outlined, "Add Card".tr, AppRoutes.ADD_CARD),
        Triple(Icons.logout, "Logout".tr, AppRoutes.LOGOUT),
      ];
}
