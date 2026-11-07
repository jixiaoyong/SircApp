import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';

void main() {
  group('AppLocale 运行时全局语言测试', () {
    test('AppLocale 支持语言列表包含 zh 和 en', () {
      const locales = AppLocale.supportedLocales;
      final languageCodes = locales.map((l) => l.languageCode).toList();
      expect(languageCodes, containsAll(['en', 'zh']));
    });

    test('AppLocale 动态切换 Locale 且正确读取中英文强类型实体', () {
      // 切换至英文
      AppLocale.setLocale(const Locale('en', 'US'));
      expect(AppLocale.current.auth.signIn, 'Sign In');
      expect(AppLocale.current.wallet.availableBalance, 'Available Balance');
      expect(Languages.auth.signIn, 'Sign In');

      // 切换至中文
      AppLocale.setLocale(const Locale('zh', 'CN'));
      expect(AppLocale.current.auth.signIn, '登录');
      expect(AppLocale.current.wallet.availableBalance, '可用余额');
      expect(Languages.auth.signIn, '登录');
    });
  });
}
