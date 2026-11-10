import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';

enum HomeChartPeriod { week, month }

class HomeChartDay {
  final DateTime date;

  /// Null means a future day, not a zero or a prediction.
  final double? amount;
  const HomeChartDay(this.date, this.amount);
}

class HomeChartData {
  final List<HomeChartDay> days;
  final int undatedCount;
  final int recordCount;
  const HomeChartData(this.days, this.undatedCount, this.recordCount);

  /// Daily money moved: abs(income) + abs(expense), never net or balance.
  factory HomeChartData.aggregate(
    List<Transaction> transactions,
    HomeChartPeriod period, {
    required DateTime now,
  }) {
    final local = now.toLocal();
    final today = DateTime(local.year, local.month, local.day);
    final start = period == HomeChartPeriod.week
        ? DateTime(today.year, today.month, today.day - today.weekday + 1)
        : DateTime(today.year, today.month);
    final count = period == HomeChartPeriod.week
        ? 7
        : DateTime(today.year, today.month + 1, 0).day;
    final dates = List.generate(
      count,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
    final totals = <DateTime, double>{};
    var undated = 0;
    var records = 0;
    final end = DateTime(start.year, start.month, start.day + count);
    for (final transaction in transactions) {
      final parsed = WalletState.transactionDate(transaction, now: local);
      if (parsed == null) {
        undated++;
        continue;
      }
      final date = DateTime(parsed.year, parsed.month, parsed.day);
      final amount = transaction.moneyAmount;
      if (date.isBefore(start) ||
          !date.isBefore(end) ||
          date.isAfter(today) ||
          amount == null ||
          !amount.isFinite) {
        continue;
      }
      records++;
      totals[date] = (totals[date] ?? 0) + amount.abs();
    }
    return HomeChartData(
      [
        for (final date in dates)
          HomeChartDay(date, date.isAfter(today) ? null : totals[date] ?? 0),
      ],
      undated,
      records,
    );
  }
}
