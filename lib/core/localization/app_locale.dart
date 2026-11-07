import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/languages.dart';
import '../storage/storage_service.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart';
export '../../data/languages.dart';

extension BuildContextL10n on BuildContext {
  /// 官方生成的强类型多语言对象快捷获取
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// 全局多语言管理
class AppLocale {
  static Locale _currentLocale = const Locale('zh', 'CN');

  static Locale get currentLocale => _currentLocale;

  static void setLocale(Locale locale) {
    _currentLocale = locale;
  }

  /// 官方强类型 Localizations 快捷获取
  static AppLocalizations? of(BuildContext context) => AppLocalizations.of(context);

  static final Map<String, Map<String, String>> _translations = Languages.keys;

  static String translate(String key) {
    final languageCode = _currentLocale.languageCode;
    final countryCode = _currentLocale.countryCode ?? '';
    final fullCode = countryCode.isNotEmpty ? '${languageCode}_$countryCode' : languageCode;

    // 优先匹配全量 tag (如 zh_CN, en_US)
    final map = _translations[fullCode] ??
        _translations[languageCode] ??
        _translations['en_US'] ??
        {};

    return map[key] ?? key;
  }
}

/// 全局翻译扩展（无缝替代 GetX 的 .tr）
extension AppTranslate on String {
  String get tr => AppLocale.translate(this);
}

class LocaleNotifier extends StateNotifier<Locale> {
  final StorageService _storageService;

  LocaleNotifier(this._storageService) : super(AppLocale.currentLocale) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final saved = _storageService.localLanguage;
    if (saved != null && saved.isNotEmpty) {
      if (saved.contains('_')) {
        final parts = saved.split('_');
        setLocale(Locale(parts[0], parts[1]));
      } else {
        setLocale(Locale(saved));
      }
    } else {
      // 优先保留 AppLocale.currentLocale 或系统语言
      if (AppLocale.currentLocale.languageCode == 'en' ||
          PlatformDispatcher.instance.locale.languageCode == 'en') {
        setLocale(const Locale('en', 'US'));
      } else {
        setLocale(const Locale('zh', 'CN'));
      }
    }
  }

  void setLocale(Locale locale) {
    state = locale;
    AppLocale.setLocale(locale);
    final code = locale.countryCode != null && locale.countryCode!.isNotEmpty
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    _storageService.setLocalLanguage(code);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return LocaleNotifier(storageService);
});
