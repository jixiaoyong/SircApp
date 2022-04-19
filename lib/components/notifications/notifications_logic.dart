import 'package:get/get.dart';

import 'notifications_state.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class NotificationsLogic extends GetxController {
  final NotificationsState state = NotificationsState();

  void setCategory(int category) {
    state.currentCategoryIndex.value = category;
  }

  void setIndexExpand(int index) {
    state.currentExpandIndex.value =
        state.currentExpandIndex.value == index ? -1 : index;
  }
}
