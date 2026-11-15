import 'package:sirc/utils/date_time_formatter.dart';

import '../models/transaction.dart';

/// 按明确时区的 ISO 时间或仅日期契约解析交易日期。
class TransactionDateParser {
  const TransactionDateParser._();

  /// 解析 [transaction] 的本地日期；非法值不使用运行时日期补造时间。
  static DateTime? parse(Transaction transaction) =>
      AppDateTimeFormatter.parseLocal(transaction.time);
}

/// Computes statistical aggregations over transactions.
class TransactionStatistics {
  const TransactionStatistics._();

  /// Calculates the transaction amounts for the 7 days of the week containing [referenceDate].
  ///
  /// The returned list has length 7, index 0 representing Monday and index 6 Sunday.
  static List<double> weeklyAmounts(
    List<Transaction> items, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    final result = List<double>.filled(7, 0);
    for (final item in items) {
      final date = TransactionDateParser.parse(item);
      if (date == null ||
          date.isBefore(start) ||
          !date.isBefore(start.add(const Duration(days: 7)))) {
        continue;
      }
      result[date.weekday - 1] += (item.moneyAmount ?? 0).abs();
    }
    return result;
  }
}
