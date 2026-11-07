import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';

void main() {
  group('Official AppLocalizations & ARB Tests', () {
    test('AppLocalizations loads English strings correctly', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      expect(loc.dashboard, 'Dashboard');
      expect(loc.wallet, 'Wallet');
      expect(loc.history, 'History');
      expect(loc.availableBalance, 'Available Balance');
      expect(loc.send, 'Send');
      expect(loc.receive, 'Receive');
      expect(loc.total, 'Total');
      expect(loc.january, 'January');
    });

    test('AppLocalizations loads Chinese strings correctly', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(loc.dashboard, '仪表盘');
      expect(loc.wallet, '钱包');
      expect(loc.history, '历史');
      expect(loc.availableBalance, '可用余额');
      expect(loc.send, '发送');
      expect(loc.receive, '接收');
      expect(loc.total, '总额');
      expect(loc.january, '一月');
    });

    test('AppLocalizations supported locales include en and zh', () {
      const locales = AppLocalizations.supportedLocales;
      final languageCodes = locales.map((l) => l.languageCode).toList();
      expect(languageCodes, containsAll(['en', 'zh']));
    });
  });
}
