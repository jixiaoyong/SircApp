import 'package:get/get.dart';

import 'person_state.dart';

/*
* @description:
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/18
*/
class PersonLogic extends GetxController {
  final PersonState state = PersonState();

  void onClick(int index) {
    state.currentIndex.value = index;
  }
}
