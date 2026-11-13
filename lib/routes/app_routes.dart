/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/17
*/
abstract class AppRoutes {
  static const INITIAL = "/";
  static const SIGN_IN = "/sign_in";
  static const SIGN_UP = "/sign_up";
  static const FORGET_PWD = "/forget_pwd";
  static const SET_PWD = "/set_pwd";
  static const MAIN = "/main";
  static const WALLET = "/wallet";
  static const HISTORY = "/history";
  static const PERSON = "/person";
  static const MENU = "/menu";

  // nested GoRoute 使用相对片段，导航与 URL 比较使用完整路径。
  static const APPEARANCE_SEGMENT = "appearance";
  static const LANGUAGES_SEGMENT = "languages";
  static const NOTIFICATIONS_SEGMENT = "notifications";
  static const PASSWORD_SEGMENT = "password";
  static const ADD_CARD_SEGMENT = "add-card";
  static const TRANSACTION_SEGMENT = "transaction";

  static const PERSON_EMAIL = "$PERSON/email";
  static const PERSON_PHONE = "$PERSON/phone";
  static const PERSON_ADDRESS = "$PERSON/address";
  static const PERSON_CARD = "$PERSON/card";

  static const MENU_APPEARANCE = "$MENU/$APPEARANCE_SEGMENT";
  static const MENU_LANGUAGES = "$MENU/$LANGUAGES_SEGMENT";
  static const MENU_NOTIFICATIONS = "$MENU/$NOTIFICATIONS_SEGMENT";
  static const MENU_PASSWORD = "$MENU/$PASSWORD_SEGMENT";
  static const ADD_CARD = "$MENU/$ADD_CARD_SEGMENT";
  static const ABOUT = "/about";
  static const WALLET_TRANSACTION = "$WALLET/$TRANSACTION_SEGMENT";
}

/// 原生 Navigator 的页面标识，不是 GoRouter URL。
abstract class AppRouteNames {
  static const webView = '/webview';
}
