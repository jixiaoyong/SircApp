import 'package:get/get.dart';
import 'package:sirc/components/card/add_card/add_card_view.dart';
import 'package:sirc/components/enter/forget_pwd/forget_pwd_view.dart';
import 'package:sirc/components/enter/set_pwd/set_pwd_view.dart';
import 'package:sirc/components/enter/sign_in/sign_in_view.dart';
import 'package:sirc/components/enter/sign_up/sign_up_view.dart';
import 'package:sirc/components/initial/initial_view.dart';
import 'package:sirc/components/language/language_view.dart';
import 'package:sirc/components/main_page.dart';
import 'package:sirc/components/not_found/not_found_view.dart';
import 'package:sirc/components/notifications/notifications_view.dart';
import 'package:sirc/components/password/password_view.dart';

import 'app_routes.dart';

/*
* @description: routes for app pages
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
class AppPages {
  static const INITIAL = AppRoutes.INITIAL;
  static final routes = [
    GetPage(name: AppRoutes.INITIAL, page: () => InitialPage()),
    GetPage(name: AppRoutes.SIGN_IN, page: () => SignInPage()),
    GetPage(name: AppRoutes.SIGN_UP, page: () => SignUpPage()),
    GetPage(name: AppRoutes.FORGET_PWD, page: () => ForgetPwdPage()),
    GetPage(name: AppRoutes.SET_PWD, page: () => SetPwdPage()),
    GetPage(name: AppRoutes.MAIN, page: () => const MainPage()),
    GetPage(name: AppRoutes.LANGUAGES, page: () => LanguagePage()),
    GetPage(name: AppRoutes.NOTIFICATIONS, page: () => NotificationsPage()),
    GetPage(name: AppRoutes.PASSWORD, page: () => PasswordPage()),
    GetPage(name: AppRoutes.ADD_CARD, page: () => AddCardPage()),
    GetPage(name: AppRoutes.NOT_FOUND, page: () => const NotFoundPage()),
  ];
}
