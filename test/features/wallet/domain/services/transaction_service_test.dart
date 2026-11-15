import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/domain/services/transaction_service.dart';

void main() {
  group('TransactionDateParser', () {
    test('UI labels and ambiguous dates stay unknown, never become now', () {
      for (final raw in [
        'Just now',
        'Today',
        '刚刚',
        '今天',
        'Yesterday',
        '昨天',
        '11/10',
        '10:30',
        'unknown',
        '2026-02-30',
        '',
        '2026 / 11 / 09',
        '2026-11-09T10:30:00',
      ]) {
        expect(TransactionDateParser.parse(Transaction(time: raw)), isNull);
      }
      expect(
        TransactionDateParser.parse(Transaction(time: '2026-11-09')),
        DateTime(2026, 11, 9),
      );
      final instant = DateTime.utc(2026, 11, 9, 10, 30).toLocal();
      for (final raw in ['2026-11-09T10:30:00Z', '2026-11-09T18:30:00+08:00']) {
        expect(TransactionDateParser.parse(Transaction(time: raw)), instant);
      }
    });
  });

  group('TransactionStatistics', () {
    final now = DateTime(2026, 11, 10, 23, 59);
    test('weeklyAmounts aggregates fixed dates, excluding invalid labels', () {
      final items = [
        for (var day = 9; day <= 15; day++)
          Transaction(
            time: '2026-11-${day.toString().padLeft(2, '0')}',
            moneyAmount: -day.toDouble(),
          ),
        Transaction(
          time: DateTime(2026, 11, 10, 12).toUtc().toIso8601String(),
          moneyAmount: 100,
        ),
        Transaction(time: '2026-11-08', moneyAmount: 999),
        Transaction(time: '2026-11-16', moneyAmount: 999),
        Transaction(time: 'Just now', moneyAmount: 999),
        Transaction(time: 'unknown', moneyAmount: 999),
      ];
      expect(TransactionStatistics.weeklyAmounts(items, referenceDate: now), [
        9,
        110,
        11,
        12,
        13,
        14,
        15,
      ]);
      expect(
        TransactionStatistics.weeklyAmounts([], referenceDate: now),
        List.filled(7, 0),
      );
    });
  });
}
