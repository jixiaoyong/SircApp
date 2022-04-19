import 'package:get/get.dart';
import 'package:sirc/components/language/language_view.dart';
import 'package:sirc/components/main_page.dart';

import 'app_routes.dart';

/*
* @description: routes for app pages
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
class AppPages {
  static const INITIAL = AppRoutes.MAIN;
  static final routes = [
    GetPage(name: AppRoutes.MAIN, page: () => MainPage()),
    GetPage(name: AppRoutes.LANGUAGES, page: () => LanguagePage())
  ];
}
