import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'initial_state.dart';

/*
* @description: Slide Menu
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/19
*/
class InitialLogic extends GetxController {
  final InitialState state = InitialState();

  @override
  Future<void> onInit() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    state.isFirstInitial.value = await prefs.getBool('isFirstInitial') ?? true;
    super.onInit();
  }

  void markAsNotFirstInitial() {
    state.isFirstInitial.value = false;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isFirstInitial', false);
    });
  }
}
