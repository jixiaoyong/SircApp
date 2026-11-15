import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sirc/l10n/impl/en/languages_en.dart';
import 'package:sirc/l10n/impl/zh/languages_zh.dart';
import 'package:sirc/utils/date_time_formatter.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  final invalid = <String?>[
    null,
    '',
    'unknown',
    '11/01',
    '14:30',
    'Just now',
    '刚刚',
    'Today',
    '今天',
    'Yesterday',
    '昨天',
    '2026-11-01T14:30:05',
    '2026 / 11 / 01 14:30:05',
    '2026/11/01',
    '2026-11-01 14:30:05Z',
    '2026-02-30',
    '2026-13-01',
    '2026-00-01',
    '2026-11-00',
    '2026-02-30T14:30:00Z',
    '2026-11-01T24:00:00Z',
    '2026-11-01T14:60:00Z',
    '2026-11-01T14:30:60Z',
    '2026-11-01T14:30:05+25:00',
    '2026-11-01T14:30:05+08:60',
  ];

  for (final entry in [
    (
      const Locale('zh', 'CN'),
      const LanguagesZhCN(),
      '2026年11月1日 14:30:05',
      '2026年11月1日',
    ),
    (
      const Locale('en', 'US'),
      const LanguagesEnUS(),
      '2026-11-01 14:30:05',
      '2026-11-01',
    ),
  ]) {
    String display(String? raw) => AppDateTimeFormatter.display(
      raw,
      locale: entry.$1,
      languages: entry.$2,
    );

    test(
      '${entry.$1} formats real instants and preserves date-only semantics',
      () {
        final local = DateTime(2026, 11, 1, 14, 30, 5);
        expect(display(local.toUtc().toIso8601String()), entry.$3);
        expect(display('2026-11-01'), entry.$4);
        expect(
          AppDateTimeFormatter.parseLocal('2026-11-01'),
          DateTime(2026, 11, 1),
        );
        expect(AppDateTimeFormatter.parseLocal('2026-11-01')!.isUtc, isFalse);
      },
    );

    test('${entry.$1} rejects invalid values without echoing UI labels', () {
      for (final raw in invalid) {
        expect(AppDateTimeFormatter.parseLocal(raw), isNull, reason: '$raw');
        expect(display(raw), '', reason: '$raw');
      }
    });

    test('${entry.$1} converts UTC and both signed offsets before display', () {
      final local = DateTime(2026, 11, 1, 14, 30, 5);
      final utc = local.toUtc();
      for (final hours in [-8, 8]) {
        final wall = utc.add(Duration(hours: hours));
        final body = wall.toIso8601String().replaceAll('Z', '');
        final raw =
            '$body${hours < 0 ? '-' : '+'}${hours.abs().toString().padLeft(2, '0')}:00';
        expect(display(raw), entry.$3);
        expect(AppDateTimeFormatter.parseLocal(raw), local);
      }
    });
  }

  test(
    'equivalent UTC/offset instants cross local date boundaries equally',
    () {
      final instant = DateTime.utc(2026, 11, 1, 0, 30, 5).toLocal();
      for (final raw in [
        '2026-11-01T00:30:05Z',
        '2026-11-01T08:30:05+08:00',
        '2026-10-31T16:30:05-08:00',
      ]) {
        expect(AppDateTimeFormatter.parseLocal(raw), instant);
        expect(AppDateTimeFormatter.parseLocal(raw)!.isUtc, isFalse);
      }
    },
  );
}
