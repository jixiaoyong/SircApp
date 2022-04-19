import 'package:get/get.dart';

import 'slide_menu_state.dart';

/*
* @description: Slide Menu
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class SlideMenuLogic extends GetxController {
  SlideMenuTapCallback? onMenuTap;

  final SlideMenuState state = SlideMenuState();
}

typedef SlideMenuTapCallback = void Function(bool open);
