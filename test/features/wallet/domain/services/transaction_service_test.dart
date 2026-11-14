import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/domain/services/transaction_service.dart';

void main() {
  group('TransactionDateParser', () {
    final now = DateTime(2026, 11, 10, 23, 59);

    test('relative labels use injected local day, unknown dates remain null', () {
      for (final label in ['Just now', 'Today', '刚刚', '今天']) {
        expect(
          TransactionDateParser.parse(Transaction(time: label), now: now),
          DateTime(2026, 11, 10),
        );
      }
      for (final label in ['Yesterday', '昨天']) {
        expect(
          TransactionDateParser.parse(Transaction(time: label), now: now),
          DateTime(2026, 11, 9),
        );
      }
      for (final label in ['11/10', '10:30', 'unknown', '2026-02-30', '']) {
        expect(
          TransactionDateParser.parse(Transaction(time: label), now: now),
          isNull,
        );
      }
      expect(
        TransactionDateParser.parse(
          Transaction(time: '2026 / 11 / 09'),
          now: now,
        ),
        DateTime(2026, 11, 9),
      );
      expect(
        TransactionDateParser.parse(
          Transaction(time: '2026-11-09T10:30:00'),
          now: now,
        ),
        DateTime(2026, 11, 9, 10, 30),
      );
      expect(
        TransactionDateParser.parse(
          Transaction(time: 'Yesterday'),
          now: DateTime(2026, 1, 1),
        ),
        DateTime(2025, 12, 31),
      );
    });
  });

  group('TransactionStatistics', () {
    final now = DateTime(2026, 11, 10, 23, 59);

    test('weeklyAmounts aggregates correctly within week boundaries', () {
      final items = [
        for (var day = 9; day <= 15; day++)
          Transaction(
            time: '2026-11-${day.toString().padLeft(2, '0')}',
            moneyAmount: -day.toDouble(),
          ),
        Transaction(time: 'Just now', moneyAmount: 100),
        Transaction(time: '2026-11-08', moneyAmount: 999),
        Transaction(time: '2026-11-16', moneyAmount: 999),
        Transaction(time: 'unknown', moneyAmount: 999),
      ];

      final amounts = TransactionStatistics.weeklyAmounts(
        items,
        referenceDate: now,
      );
      expect(amounts, [9, 110, 11, 12, 13, 14, 15]);
      expect(
        TransactionStatistics.weeklyAmounts([], referenceDate: now),
        List.filled(7, 0),
      );
    });
  });
}
