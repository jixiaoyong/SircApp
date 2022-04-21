import 'package:get/get.dart';

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
    super.onInit();
  }
}

typedef SlideMenuTapCallback = void Function(bool open);
