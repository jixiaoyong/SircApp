import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sirc/bean/pair.dart';

/*
* @description: Slide Menu
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class SlideMenuState {
  final List<Pair<IconData, String>> slideMenuList = [
    Pair(Icons.home_outlined, "Home".tr),
    Pair(Icons.person_outline, "Profile".tr),
    Pair(Icons.history_outlined, "History".tr),
    Pair(Icons.notifications_outlined, "Notifications".tr),
    Pair(Icons.settings, "Settings".tr),
    Pair(Icons.help_outline_outlined, "Help & Support".tr),
  ];
}
