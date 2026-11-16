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

  /// 将已筛选的 [items] 按 [period]（0 全部、1 本周、2 本月）分桶。
  ///
  /// [referenceDate] 决定周/月边界；全部范围从最早交易年份的 1 月补齐至最晚交易月份。
  /// 无有效日期时全部范围返回空桶，金额统一累加绝对值。
  static ({List<DateTime> dates, List<double> values}) historyBuckets(
    List<Transaction> items, {
    required int period,
    required DateTime referenceDate,
  }) {
    final dated = [
      for (final item in items)
        if (TransactionDateParser.parse(item) case final DateTime date)
          (date: date, amount: (item.moneyAmount ?? 0).abs()),
    ];
    final dates = <DateTime>[];
    if (period == 1) {
      final today = DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
      );
      final monday = DateTime(
        today.year,
        today.month,
        today.day - today.weekday + 1,
      );
      dates.addAll(
        List.generate(
          7,
          (i) => DateTime(monday.year, monday.month, monday.day + i),
        ),
      );
    } else if (period == 2) {
      final days = DateTime(referenceDate.year, referenceDate.month + 1, 0).day;
      dates.addAll(
        List.generate(
          days,
          (i) => DateTime(referenceDate.year, referenceDate.month, i + 1),
        ),
      );
    } else if (dated.isNotEmpty) {
      final months = dated.map(
        (item) => item.date.year * 12 + item.date.month - 1,
      );
      final first = months.reduce((a, b) => a < b ? a : b) ~/ 12 * 12;
      final last = months.reduce((a, b) => a > b ? a : b);
      dates.addAll(
        List.generate(
          last - first + 1,
          (i) => DateTime((first + i) ~/ 12, (first + i) % 12 + 1),
        ),
      );
    }
    final values = List<double>.filled(dates.length, 0);
    final indices = <DateTime, int>{
      for (var i = 0; i < dates.length; i++) dates[i]: i,
    };
    for (final item in dated) {
      final key = period == 0
          ? DateTime(item.date.year, item.date.month)
          : DateTime(item.date.year, item.date.month, item.date.day);
      final index = indices[key];
      if (index != null) values[index] += item.amount;
    }
    return (dates: dates, values: values);
  }

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
