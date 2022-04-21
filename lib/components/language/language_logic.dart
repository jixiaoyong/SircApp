import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/data/common_keys.dart';

import '../main_app_logic.dart';

class LanguageLogic extends GetxController {
  SharedPreferences? _prefs;
  final MainAppLogic _appLogic = Get.find();

  @override
  Future<void> onInit() async {
    _prefs = await SharedPreferences.getInstance();
    super.onInit();
  }

  // other logic can change their local value by listener to this variable
  // just for mock
  var languageChangedTimeMillis = 0.obs;

  void updateLanguage(Locale locale, String languagesName) {
    languageChangedTimeMillis.value = DateTime.now().millisecondsSinceEpoch;
    Get.updateLocale(locale);
    _appLogic.setLocalLanguage(locale);
    _prefs?.setString(CommonKeys.LOCAL_LANGUAGE, languagesName);
  }
}
