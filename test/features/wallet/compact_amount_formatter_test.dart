import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/features/wallet/domain/utils/compact_amount_formatter.dart';

const englishUnits = <(double, String)>[
  (1e12, 'T'),
  (1e9, 'B'),
  (1e6, 'M'),
  (1e3, 'K'),
];
const chineseUnits = <(double, String)>[(1e12, '万亿'), (1e8, '亿'), (1e4, '万')];

void main() {
  group('CompactAmountFormatter', () {
    test('formats English compact units with two decimals', () {
      expect(
        CompactAmountFormatter.format(112340, units: englishUnits),
        '112.34K',
      );
      expect(
        CompactAmountFormatter.format(12340000, units: englishUnits),
        '12.34M',
      );
      expect(
        CompactAmountFormatter.format(1234000000, units: englishUnits),
        '1.23B',
      );
      expect(
        CompactAmountFormatter.format(1234000000000, units: englishUnits),
        '1.23T',
      );
    });

    test('formats Chinese compact units with two decimals', () {
      expect(
        CompactAmountFormatter.format(12340, units: chineseUnits),
        '1.23万',
      );
      expect(
        CompactAmountFormatter.format(123400000, units: chineseUnits),
        '1.23亿',
      );
      expect(
        CompactAmountFormatter.format(1234000000000, units: chineseUnits),
        '1.23万亿',
      );
    });

    test(
      'rounds across unit boundaries and leaves small amounts unchanged',
      () {
        expect(
          CompactAmountFormatter.format(999999.99, units: englishUnits),
          '1.00M',
        );
        expect(
          CompactAmountFormatter.format(123.456, units: englishUnits),
          '123.46',
        );
        expect(
          CompactAmountFormatter.format(-12345.678, units: englishUnits),
          '12.35K',
        );
        expect(CompactAmountFormatter.format(0, units: chineseUnits), '0.00');
      },
    );
  });
}
