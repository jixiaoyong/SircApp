/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 22/04/20
*/
class CommonKeys {
  // is first time to launch app
  static const String IS_FIRST_INITIAL = 'isFirstInitial';
  static const String IS_LOGIN_SUCCESS = 'isLoginSuccess';

  // the language of app
  static const String LOCAL_LANGUAGE = 'localLanguage';
  // Device appearance preference survives logout and account data cleanup.
  static const String THEME_MODE = 'themeMode';
  static const String USER_NAME = 'user_name';

  // the md5 of user password
  static const String USER_PWD = 'user_pwd';
  static const String USER_EMAIL = 'user_email';

  // Persisted bank cards diffs (user added / deleted / updated)
  static const String ADDED_BANK_CARDS = 'added_bank_cards';
  static const String DELETED_BANK_CARD_IDS = 'deleted_bank_card_ids';
  static const String CARD_OVERRIDES = 'card_overrides';
}
