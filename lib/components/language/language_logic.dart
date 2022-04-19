import 'dart:ui';

import 'package:get/get.dart';

class LanguageLogic extends GetxController {
  // other logic can change their local value by listener to this variable
  // just for mock
  var languageChangedTimeMillis = 0.obs;

  void updateLanguage(Locale locale) {
    languageChangedTimeMillis.value = DateTime.now().millisecondsSinceEpoch;
    Get.updateLocale(locale);
  }
}
