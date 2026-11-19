import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/localization/transaction_localization.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';

void main() {
  late Locale originalLocale;
  setUp(() {
    originalLocale = AppLocale.currentLocale;
  });
  tearDown(() {
    AppLocale.setLocale(originalLocale);
  });

  for (final entry in [
    (const Locale('zh', 'CN'), '某件事'),
    (const Locale('en', 'US'), 'Something'),
  ]) {
    test(
      '${entry.$1} relocalizes only names, preserving ISO business time',
      () {
        AppLocale.setLocale(entry.$1);
        for (final name in ['Something', '某件事']) {
          for (final time in [
            '2026-11-09T14:00:00Z',
            '2026-11-09T22:00:00+08:00',
            '2026-11-09',
          ]) {
            final transaction = Transaction(
              moneyActionName: name,
              time: time,
              moneyAmount: -12.34,
              userIcon: 'avatar',
            );
            final localized = transaction.localizedPlaceholders;
            expect(localized.moneyActionName, entry.$2);
            expect(localized.time, time);
            expect(localized.moneyAmount, -12.34);
            expect(localized.userIcon, 'avatar');
            expect(transaction.moneyActionName, name);
            expect(transaction.time, time);
          }
        }
      },
    );

    test(
      '${entry.$1} mapper never translates time, even invalid legacy input',
      () {
        AppLocale.setLocale(entry.$1);
        for (final time in [
          'Just now',
          '刚刚',
          'Today',
          '今天',
          'Yesterday',
          '昨天',
        ]) {
          expect(
            Transaction(
              moneyActionName: 'Coffee',
              time: time,
            ).localizedPlaceholders.time,
            time,
          );
        }
        expect(
          Transaction(moneyActionName: 'Coffee')
              .localizedPlaceholders
              .moneyActionName,
          'Coffee',
        );
        expect(Transaction().localizedPlaceholders.time, isNull);
      },
    );
  }
}
