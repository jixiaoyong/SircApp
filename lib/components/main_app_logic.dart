import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sirc/components/main_app_state.dart';

/*
* @description: all application commom logic and state
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class MainAppLogic extends GetxController {
  MainAppState state = MainAppState();

  var userName = ''.obs;
  var userEmail = ''.obs;
  // just for mock, we set a default value
  var userAvatar = 'https://s3.bmp.ovh/imgs/2022/04/22/b352d638990f1e84.webp'.obs;

  final Rx<Locale?> _currentLocal = Rx(null); 

  @override
  void onInit() {
    super.onInit();
    listenLocalChange((local) {
      state.bnbItems.value = state.generateBnbItems();
    });
  }

  void setUserInfo(String? name, String? email) {
    userName.value = name ?? "JI,XIAOYONG";
    userEmail.value = email ?? "jixiaoyong1995@gmail.com";
  }

  void updateUserAvatar(String avatar) {
    userAvatar.value = avatar;
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
