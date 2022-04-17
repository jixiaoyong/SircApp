import 'package:get/get.dart';

import 'home_page_state.dart';

class HomePageLogic extends GetxController {
  final HomePageState state = HomePageState();

  void setBankIndex(int index) {
    state.currentBankIndex.value = index;
  }
}
