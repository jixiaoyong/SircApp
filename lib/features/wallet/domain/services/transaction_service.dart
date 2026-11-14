import '../models/transaction.dart';

/// Service for parsing transaction dates from raw text representations.
class TransactionDateParser {
  const TransactionDateParser._();

  /// Parses transaction date with relative or absolute format.
  ///
  /// Relative labels have day-level precision only; never invent a time of day.
  static DateTime? parse(Transaction transaction, {DateTime? now}) {
    final text = transaction.time?.trim() ?? '';
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    switch (text.toLowerCase()) {
      case 'just now':
      case 'today':
      case '刚刚':
      case '今天':
        return today;
      case 'yesterday':
      case '昨天':
        return DateTime(today.year, today.month, today.day - 1);
    }
    // Full ISO/slash dates remain compatible. Month/day and time-only strings
    // have no reliable year/day and intentionally remain undated.
    final normalized = text.replaceAll(RegExp(r'\s*/\s*'), '-');
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}(?:$|[T ])').hasMatch(normalized)) {
      return null;
    }
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return null;
    final parts = normalized
        .substring(0, 10)
        .split('-')
        .map(int.parse)
        .toList();
    final date = DateTime(parts[0], parts[1], parts[2]);
    if (date.month != parts[1] || date.day != parts[2]) return null;
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }
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
      final date = TransactionDateParser.parse(item, now: referenceDate);
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
