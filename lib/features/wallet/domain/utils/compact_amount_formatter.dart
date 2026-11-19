/// Formats an absolute amount using caller-provided localized compact unit labels.
class CompactAmountFormatter {
  const CompactAmountFormatter._();

  static String format(double value, {required List<(double, String)> units}) {
    final absolute = value.abs();
    for (var index = 0; index < units.length; index++) {
      final (threshold, suffix) = units[index];
      if (absolute >= threshold) {
        final roundedValue = double.parse(
          (absolute / threshold).toStringAsFixed(2),
        );
        if (index > 0 && roundedValue >= units[index - 1].$1 / threshold) {
          final (nextThreshold, nextSuffix) = units[index - 1];
          return '${(absolute / nextThreshold).toStringAsFixed(2)}$nextSuffix';
        }
        return '${roundedValue.toStringAsFixed(2)}$suffix';
      }
    }
    return absolute.toStringAsFixed(2);
  }
}
