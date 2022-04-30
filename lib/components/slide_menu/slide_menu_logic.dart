import 'package:flutter/src/widgets/icon_data.dart';
import 'package:get/get.dart';
import 'package:sirc/bean/pair.dart';
import 'package:sirc/routes/app_routes.dart';

import '../main_app_logic.dart';
import 'slide_menu_state.dart';

/*
* @description: Slide Menu
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class SlideMenuLogic extends GetxController {
  final SlideMenuState state = SlideMenuState();

  final MainAppLogic _mainAppLogic = Get.find();
  SlideMenuTapCallback? onMenuTap;

  @override
  void onInit() {
    _mainAppLogic.listenLocalChange((p0) {
      state.slideMenuList.value = SlideMenuState.generateSlideMenuList();
    });

    state.username = _mainAppLogic.userName;
    state.email = _mainAppLogic.userEmail;
    state.avatar = _mainAppLogic.userAvatar;
    super.onInit();
  }

  void onMenuItemClick(Pair<IconData, String> item) {
    // usually we need to deal with all the click event one by one, this is just a demo
    if ("About".tr == item.second) {
      Get.toNamed(AppRoutes.ABOUT);
    }
  }
}

typedef SlideMenuTapCallback = void Function(bool open);
