import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/common_keys.dart';

/// 全局 SharedPreferences 实例 Provider，由 main.dart 在启动时初始化并 override
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

/// 本地持久化服务封装，支持 SharedPreferences 与单测内存缓存双模式
class StorageService extends ChangeNotifier {
  final SharedPreferences? _prefs;

  StorageService([this._prefs]);

  bool get isFirstInitial =>
      _prefs?.getBool(CommonKeys.IS_FIRST_INITIAL) ?? true;
  Future<bool> setFirstInitial(bool value) async {
    final result = await _prefs?.setBool(CommonKeys.IS_FIRST_INITIAL, value);
    return result ?? true;
  }

  bool get isLoginSuccess =>
      _prefs?.getBool(CommonKeys.IS_LOGIN_SUCCESS) ?? false;
  Future<bool> setLoginSuccess(bool value) async {
    final result = await _prefs?.setBool(CommonKeys.IS_LOGIN_SUCCESS, value);
    notifyListeners();
    return result ?? true;
  }

  String? get userName => _prefs?.getString(CommonKeys.USER_NAME);
  Future<bool> setUserName(String value) async {
    final result = await _prefs?.setString(CommonKeys.USER_NAME, value);
    return result ?? true;
  }

  String? get userPwd => _prefs?.getString(CommonKeys.USER_PWD);
  Future<bool> setUserPwd(String value) async {
    final result = await _prefs?.setString(CommonKeys.USER_PWD, value);
    return result ?? true;
  }

  String? get userEmail => _prefs?.getString(CommonKeys.USER_EMAIL);
  Future<bool> setUserEmail(String value) async {
    final result = await _prefs?.setString(CommonKeys.USER_EMAIL, value);
    return result ?? true;
  }

  String? get localLanguage => _prefs?.getString(CommonKeys.LOCAL_LANGUAGE);
  Future<bool> setLocalLanguage(String value) async {
    final result = await _prefs?.setString(CommonKeys.LOCAL_LANGUAGE, value);
    return result ?? true;
  }

  String? get themeMode => _prefs?.getString(CommonKeys.THEME_MODE);
  Future<bool> setThemeMode(String value) async =>
      await _prefs?.setString(CommonKeys.THEME_MODE, value) ?? true;

  List<String>? get addedBankCardsJson =>
      _prefs?.getStringList(CommonKeys.ADDED_BANK_CARDS);
  Future<bool> setAddedBankCardsJson(List<String> value) async {
    final result =
        await _prefs?.setStringList(CommonKeys.ADDED_BANK_CARDS, value);
    return result ?? true;
  }

  List<String>? get deletedBankCardIds =>
      _prefs?.getStringList(CommonKeys.DELETED_BANK_CARD_IDS);
  Future<bool> setDeletedBankCardIds(List<String> value) async {
    final result =
        await _prefs?.setStringList(CommonKeys.DELETED_BANK_CARD_IDS, value);
    return result ?? true;
  }

  List<String>? get cardOverridesJson =>
      _prefs?.getStringList(CommonKeys.CARD_OVERRIDES);
  Future<bool> setCardOverridesJson(List<String> value) async {
    final result =
        await _prefs?.setStringList(CommonKeys.CARD_OVERRIDES, value);
    return result ?? true;
  }

  /// Match the menu's existing full cleanup, retaining device appearance only.
  Future<void> clearUserData() async {
    for (final key in _prefs?.getKeys() ?? <String>{}) {
      if (key != CommonKeys.THEME_MODE) await _prefs?.remove(key);
    }
  }

  Future<bool> clearUser() async {
    await _prefs?.remove(CommonKeys.IS_LOGIN_SUCCESS);
    notifyListeners();
    return true;
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final storage = StorageService(prefs);
  ref.onDispose(storage.dispose);
  return storage;
});
