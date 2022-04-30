import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirc/bean/pair.dart';

/*
* @description: Slide Menu
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class SlideMenuState {
  var username = "".obs;
  var email = "".obs;
  var avatar = "".obs;

  final Rx<List<Pair<IconData, String>>> slideMenuList =
      Rx(generateSlideMenuList());


  static generateSlideMenuList() => [
        Pair(Icons.home_outlined, "Home".tr),
        Pair(Icons.person_outline, "Profile".tr),
        Pair(Icons.history_outlined, "History".tr),
        Pair(Icons.notifications_outlined, "Notifications".tr),
        Pair(Icons.settings, "Settings".tr),
        Pair(Icons.help_outline_outlined, "About".tr),
      ];
}
