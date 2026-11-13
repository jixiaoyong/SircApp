import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/localization/transaction_localization.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/mock/mock_utils.dart';

void main() {
  late Locale originalLocale;

  setUp(() {
    originalLocale = AppLocale.currentLocale;
  });

  tearDown(() {
    AppLocale.setLocale(originalLocale);
  });

  for (final entry in [
    (const Locale('zh', 'CN'), '某件事', '刚刚'),
    (const Locale('en', 'US'), 'Something', 'Just now'),
  ]) {
    test('${entry.$1} has correctly mapped typed and legacy keys', () {
      AppLocale.setLocale(entry.$1);
      expect(Languages.something, entry.$2);
      expect(Languages.justNow, entry.$3);
      expect(AppLocale.translate('Something'), entry.$2);
      expect(AppLocale.translate('Just now'), entry.$3);
    });

    test(
      '${entry.$1} relocalizes cached placeholders without changing data',
      () {
        AppLocale.setLocale(entry.$1);
        for (final source in [
          ('Something', 'Just now'),
          ('某件事', '刚刚'),
          ('某些东西', '刚刚'),
        ]) {
          final transaction = Transaction(
            moneyActionName: source.$1,
            time: source.$2,
            moneyAmount: -12.34,
            userIcon: 'avatar',
          );
          final localized = transaction.localizedPlaceholders;
          expect(localized.moneyActionName, entry.$2);
          expect(localized.time, entry.$3);
          expect(localized.moneyAmount, -12.34);
          expect(localized.userIcon, 'avatar');
          expect(transaction.moneyActionName, source.$1);
          expect(transaction.time, source.$2);
        }
      },
    );

    test('${entry.$1} preserves actual transaction names and timestamps', () {
      AppLocale.setLocale(entry.$1);
      for (final time in [
        '2026-11-09T14:00:00Z',
        '2026-11-09T22:00:00+08:00',
      ]) {
        final transaction = Transaction(moneyActionName: 'Coffee', time: time);
        expect(transaction.localizedPlaceholders.moneyActionName, 'Coffee');
        expect(transaction.localizedPlaceholders.time, time);
      }
      final empty = Transaction().localizedPlaceholders;
      expect(empty.moneyActionName, isNull);
      expect(empty.time, isNull);
    });
  }

  test(
    'cached mock list follows both language switches at presentation time',
    () {
      AppLocale.setLocale(const Locale('en', 'US'));
      final cached = MockUtils.moneyOperateList;
      final amounts = cached
          .map((transaction) => transaction.moneyAmount)
          .toList();
      for (final entry in [
        (const Locale('zh', 'CN'), '某件事', '刚刚'),
        (const Locale('en', 'US'), 'Something', 'Just now'),
      ]) {
        AppLocale.setLocale(entry.$1);
        for (final transaction in cached) {
          expect(transaction.localizedPlaceholders.moneyActionName, entry.$2);
          expect(transaction.localizedPlaceholders.time, entry.$3);
        }
        expect(
          cached.map((transaction) => transaction.moneyAmount).toList(),
          amounts,
        );
      }
    },
  );
}
