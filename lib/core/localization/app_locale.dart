import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/impl/en/languages_en.dart';
import '../../l10n/impl/zh/languages_zh.dart';
import '../../l10n/lang_keys.dart';
import '../../l10n/languages.g.dart';
import '../storage/storage_service.dart';

export '../../l10n/lang_keys.dart';
export '../../l10n/languages.g.dart';

/// 全局多语言管理
class AppLocale {
  static Locale _currentLocale = const Locale('zh', 'CN');

  static Locale get currentLocale => _currentLocale;

  static void setLocale(Locale locale) {
    _currentLocale = locale;
  }

  /// 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
    Locale('zh'),
    Locale('en'),
  ];

  static const LangKeys _zhCN = LanguagesZhCN();
  static const LangKeys _enUS = LanguagesEnUS();

  /// 当前激活的强类型多语言接口实体（O(1) 内存属性直寻）
  static LangKeys get current {
    if (_currentLocale.languageCode == 'en') {
      return _enUS;
    }
    return _zhCN;
  }

  static final Map<String, Map<String, String>> _translations = Languages.keys;

  /// 兼容旧版字符串 Key 翻译
  static String translate(String key) {
    final languageCode = _currentLocale.languageCode;
    final countryCode = _currentLocale.countryCode ?? '';
    final fullCode = countryCode.isNotEmpty
        ? '${languageCode}_$countryCode'
        : languageCode;

    // 优先匹配全量 tag (如 zh_CN, en_US)
    final map =
        _translations[fullCode] ??
        _translations[languageCode] ??
        _translations['en_US'] ??
        {};

    return map[key] ?? key;
  }
}

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final storage = ref.watch(storageServiceProvider);
    final saved = storage.localLanguage;
    if (saved != null && saved.isNotEmpty) {
      if (saved.contains('_')) {
        final parts = saved.split('_');
        final loc = Locale(parts[0], parts[1]);
        AppLocale.setLocale(loc);
        return loc;
      } else {
        final loc = Locale(saved);
        AppLocale.setLocale(loc);
        return loc;
      }
    } else {
      if (AppLocale.currentLocale.languageCode == 'en' ||
          PlatformDispatcher.instance.locale.languageCode == 'en') {
        const loc = Locale('en', 'US');
        AppLocale.setLocale(loc);
        return loc;
      } else {
        const loc = Locale('zh', 'CN');
        AppLocale.setLocale(loc);
        return loc;
      }
    }
  }

  void setLocale(Locale locale) {
    state = locale;
    AppLocale.setLocale(locale);
    final code = locale.countryCode != null && locale.countryCode!.isNotEmpty
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    ref.read(storageServiceProvider).setLocalLanguage(code);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
