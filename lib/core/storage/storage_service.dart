import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/common_keys.dart';

/// 全局 SharedPreferences 实例 Provider，由 main.dart 在启动时初始化并 override
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

/// 本地持久化服务封装，支持 SharedPreferences 与单测内存缓存双模式
class StorageService {
  final SharedPreferences? _prefs;
  final Map<String, Object> _memoryCache = {};

  StorageService([this._prefs]);

  bool get isFirstInitial =>
      _prefs?.getBool(CommonKeys.IS_FIRST_INITIAL) ??
      (_memoryCache[CommonKeys.IS_FIRST_INITIAL] as bool?) ??
      true;
  Future<bool> setFirstInitial(bool value) async {
    _memoryCache[CommonKeys.IS_FIRST_INITIAL] = value;
    final result = await _prefs?.setBool(CommonKeys.IS_FIRST_INITIAL, value);
    return result ?? true;
  }

  bool get isLoginSuccess =>
      _prefs?.getBool(CommonKeys.IS_LOGIN_SUCCESS) ??
      (_memoryCache[CommonKeys.IS_LOGIN_SUCCESS] as bool?) ??
      false;
  Future<bool> setLoginSuccess(bool value) async {
    _memoryCache[CommonKeys.IS_LOGIN_SUCCESS] = value;
    final result = await _prefs?.setBool(CommonKeys.IS_LOGIN_SUCCESS, value);
    return result ?? true;
  }

  String? get userName =>
      _prefs?.getString(CommonKeys.USER_NAME) ??
      (_memoryCache[CommonKeys.USER_NAME] as String?);
  Future<bool> setUserName(String value) async {
    _memoryCache[CommonKeys.USER_NAME] = value;
    final result = await _prefs?.setString(CommonKeys.USER_NAME, value);
    return result ?? true;
  }

  String? get userPwd =>
      _prefs?.getString(CommonKeys.USER_PWD) ??
      (_memoryCache[CommonKeys.USER_PWD] as String?);
  Future<bool> setUserPwd(String value) async {
    _memoryCache[CommonKeys.USER_PWD] = value;
    final result = await _prefs?.setString(CommonKeys.USER_PWD, value);
    return result ?? true;
  }

  String? get userEmail =>
      _prefs?.getString(CommonKeys.USER_EMAIL) ??
      (_memoryCache[CommonKeys.USER_EMAIL] as String?);
  Future<bool> setUserEmail(String value) async {
    _memoryCache[CommonKeys.USER_EMAIL] = value;
    final result = await _prefs?.setString(CommonKeys.USER_EMAIL, value);
    return result ?? true;
  }

  String? get localLanguage =>
      _prefs?.getString(CommonKeys.LOCAL_LANGUAGE) ??
      (_memoryCache[CommonKeys.LOCAL_LANGUAGE] as String?);
  Future<bool> setLocalLanguage(String value) async {
    _memoryCache[CommonKeys.LOCAL_LANGUAGE] = value;
    final result = await _prefs?.setString(CommonKeys.LOCAL_LANGUAGE, value);
    return result ?? true;
  }

  Future<bool> clearUser() async {
    _memoryCache.remove(CommonKeys.IS_LOGIN_SUCCESS);
    await _prefs?.remove(CommonKeys.IS_LOGIN_SUCCESS);
    return true;
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});
