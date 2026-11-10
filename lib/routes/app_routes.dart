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
  static const LANGUAGES_SEGMENT = "languages";
  static const NOTIFICATIONS_SEGMENT = "notifications";
  static const PASSWORD_SEGMENT = "password";
  static const ADD_CARD_SEGMENT = "add-card";
  static const TRANSACTION_SEGMENT = "transaction";

  static const MENU_LANGUAGES = "$MENU/$LANGUAGES_SEGMENT";
  static const MENU_NOTIFICATIONS = "$MENU/$NOTIFICATIONS_SEGMENT";
  static const MENU_PASSWORD = "$MENU/$PASSWORD_SEGMENT";
  static const FINGERPRINT = "/fingerprint";
  static const ADD_CARD = "$MENU/$ADD_CARD_SEGMENT";
  static const LOGOUT = "/logout";
  static const NOT_FOUND = "/not_found";
  static const ABOUT = "/about";
  static const HISTORY_DETAILS = "/history_details";
  static const WALLET_TRANSACTION = "$WALLET/$TRANSACTION_SEGMENT";
  static const WEBVIEW = "/webview";
}
