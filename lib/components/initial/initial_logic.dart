import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/data/common_keys.dart';

import '../../routes/app_routes.dart';
import '../main_app_logic.dart';
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
  final MainAppLogic _appLogic = Get.put(MainAppLogic(), permanent: true);

  SharedPreferences? _prefs;

  @override
  Future<void> onInit() async {
    // Obtain shared preferences.
    _prefs = await SharedPreferences.getInstance();
    state.isFirstInitial.value =
        _prefs?.getBool(CommonKeys.IS_FIRST_INITIAL) ?? true;

    var userName = _prefs?.getString(CommonKeys.USER_NAME);
    var userEmail = _prefs?.getString(CommonKeys.USER_EMAIL);
    _appLogic.setUserInfo(userName, userEmail);

    initialLocalLanguage();

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();

    if (true != state.isFirstInitial.value) {
      Future.delayed(const Duration(seconds: 3), () {
        goMainPage();
      });
    }
  }

  Future<void> goMainPage() async {
    bool? isLoginSuccess = isUserLoggedIn();
    if (!isLoginSuccess) {
      isLoginSuccess = await Get.toNamed(AppRoutes.SIGN_IN);
    }

    if (isLoginSuccess == true) {
      Get.offAndToNamed(AppRoutes.MAIN);
      markAsNotFirstInitial();
    } else {
      Get.offAndToNamed(AppRoutes.SIGN_IN);
    }
  }

  void initialLocalLanguage() {
    var localLanguage = _prefs?.getString(CommonKeys.LOCAL_LANGUAGE);
    if (localLanguage != null && localLanguage.isNotEmpty) {
      var locationStrArr = localLanguage.split("_");
      var locale = Locale(locationStrArr.first, locationStrArr.last);
      Get.locale = locale;
      _appLogic.setLocalLanguage(locale);
    }
  }

  void markAsNotFirstInitial() {
    state.isFirstInitial.value = false;
    _prefs?.setBool(CommonKeys.IS_FIRST_INITIAL, false);
  }

  // is user has logged in,not matter whether pwd is correct or not
  bool isUserLoggedIn() {
    var isLoginSuccess = _prefs?.getBool(CommonKeys.IS_LOGIN_SUCCESS);
    return isLoginSuccess == true;
  }
}
