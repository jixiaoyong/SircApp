import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sirc/components/main_app_logic.dart';

import 'home_page_state.dart';

class HomePageLogic extends GetxController {
  final HomePageState state = HomePageState();

  @override
  void onReady() {
    // wait for main app logic init
    final MainAppLogic _mainAppLogic = Get.find();
    state.userAvatar = _mainAppLogic.userAvatar;
    super.onReady();
  }

  void setBankIndex(int index) {
    state.currentBankIndex.value = index;
  }

  void jumpToPage(int index) {
    state.pageController.animateToPage(index,
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }
}
