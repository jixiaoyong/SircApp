import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sirc/components/main_app_state.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class MainAppLogic extends GetxController {
  MainAppState state = MainAppState();

  var userName = ''.obs;

  final Rx<Locale?> _currentLocal = Rx(null);

  @override
  void onInit() {
    super.onInit();
    listenLocalChange((local) {
      state.bnbItems.value = state.generateBnbItems();
    });
  }

  void setUserInfo(String? name) {
    userName.value = name ?? "JI,XIAOYONG";
  }

  void setLocalLanguage(Locale locale) {
    _currentLocal.value = locale;
  }

  void listenLocalChange(Function(Locale?) onChange) {
    _currentLocal.listen((p0) {
      onChange(p0);
    });
  }

  void changeIndex(int index) {
    state.currentIndex.value = index;
  }
}
