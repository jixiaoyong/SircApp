import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'home_page_state.dart';

class HomePageLogic extends GetxController {
  final HomePageState state = HomePageState();

  void setBankIndex(int index) {
    state.currentBankIndex.value = index;
  }

  void jumpToPage(int index) {
    state.pageController.animateToPage(index,
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }
}
