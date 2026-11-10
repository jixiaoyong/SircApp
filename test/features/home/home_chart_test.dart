import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/home_chart_data.dart';
import 'package:sirc/features/home/presentation/home_transaction_chart.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/widgets/line_graph.dart';

class ChartTestWallet extends WalletController {
  @override
  WalletState build() => WalletState(
    moneyTypes: const [],
    selectedMonth: '',
    monthEnglishNameList: const [],
    referenceDate: DateTime(2026, 11, 11),
    allTransactions: [
      Transaction(time: '2026-11-09', moneyAmount: -20),
      Transaction(time: '2026-11-09', moneyAmount: 30),
    ],
  );
  void replace(List<Transaction> items) =>
      state = state.copyWith(allTransactions: items);
  void loading() => state = state.copyWith(isLoading: true);
  void fail() =>
      state = state.copyWith(isLoading: false, errorMessage: () => 'Failure');
}

void main() {
  test('calendar boundaries, gross amounts, unknown and future dates', () {
    final chart = HomeChartData.aggregate(
      [
        Transaction(time: '2025-12-29', moneyAmount: -20),
        Transaction(time: '2025-12-29', moneyAmount: 30),
        Transaction(time: '2026-01-04', moneyAmount: 99),
        Transaction(time: 'bad', moneyAmount: 10),
        Transaction(time: '2025-12-28', moneyAmount: 100),
      ],
      HomeChartPeriod.week,
      now: DateTime(2026, 1, 1),
    );
    expect(chart.days.length, 7);
    expect(chart.days.first.date, DateTime(2025, 12, 29));
    expect(chart.days.last.date, DateTime(2026, 1, 4));
    expect(chart.days.map((e) => e.amount), [50, 0, 0, 0, null, null, null]);
    expect(chart.recordCount, 2);
    expect(chart.undatedCount, 1);
  });

  test('28–31 days and leap year, relative and timezone date parsing', () {
    for (final entry in [
      (2025, 2, 28),
      (2024, 2, 29),
      (2026, 4, 30),
      (2026, 1, 31),
    ]) {
      final result = HomeChartData.aggregate(
        [],
        HomeChartPeriod.month,
        now: DateTime(entry.$1, entry.$2, 10),
      );
      expect(result.days.length, entry.$3);
      expect(result.days.first.date.day, 1);
      expect(result.days[9].amount, 0);
      expect(result.days[10].amount, isNull);
    }
    final date = DateTime.utc(2026, 11, 10, 23).toLocal();
    final data = HomeChartData.aggregate(
      [
        Transaction(time: '2026-11-10T23:00:00Z', moneyAmount: 12),
        Transaction(time: 'Today', moneyAmount: -8),
        Transaction(time: '2026-02-30', moneyAmount: 80),
      ],
      HomeChartPeriod.month,
      now: DateTime(2026, 11, 20),
    );
    expect(data.days[date.day - 1].amount, 12);
    expect(data.days[19].amount, 8);
    expect(data.undatedCount, 1);
  });

  test('zero based nice ticks and monthly thinning keep all points', () {
    final axis = AmountAxis.forValues([0, 183, null]);
    expect(axis.ticks.first, 0);
    expect(axis.maximum, greaterThan(183));
    expect(AmountAxis.forValues([0, null]).maximum, 100);
    final data = List.generate(
      31,
      (i) => ChartDataPoint('${i + 1}', 'day ${i + 1}', i.toDouble()),
    );
    final painter = LinerGraphPainter(
      data,
      axis: axis,
      monthly: true,
      selected: null,
      textScaler: TextScaler.noScaling,
      lineColor: Colors.blue,
      labelColor: Colors.grey,
      axisColor: Colors.grey,
    );
    final labels = painter.labelIndices(const Size(180, 200));
    expect(labels.length, lessThan(31));
    expect(labels.first, 0);
    expect(labels.last, 30);
    expect(painter.data.length, 31);
  });

  Future<ProviderContainer> pumpChart(
    WidgetTester tester, {
    double width = 600,
    double scale = 1,
  }) async {
    final container = ProviderContainer(
      overrides: [walletControllerProvider.overrideWith(ChartTestWallet.new)],
    );
    // Avoid storage/locale dependencies while still testing reactive language rebuilds.
    container.read(localeProvider.notifier).setLocale(const Locale('en', 'US'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Center(
                child: SizedBox(
                  width: width,
                  child: const SingleChildScrollView(
                    child: HomeTransactionChart(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return container;
  }

  testWidgets(
    'week/month switching, tooltip, updates and wallet independence',
    (tester) async {
      final container = await pumpChart(tester);
      var graph = tester.widget<LineGraph>(find.byType(LineGraph));
      expect(graph.data.length, 7);
      expect(graph.data.first.value, 50);
      await tester.tap(find.byKey(const ValueKey('home-chart-period-1')));
      await tester.pump();
      graph = tester.widget<LineGraph>(find.byType(LineGraph));
      expect(graph.data.length, 30);
      expect(graph.data[8].value, 50);
      expect(find.text('November'), findsOneWidget);
      expect(container.read(walletControllerProvider).currentFilterIndex, 0);
      await tester.tapAt(tester.getCenter(find.byType(LineGraph)));
      await tester.pump();
      expect(find.byKey(const ValueKey('chart-tooltip')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('home-chart-period-0')));
      await tester.pump();
      expect(find.byKey(const ValueKey('chart-tooltip')), findsNothing);
      final controller =
          container.read(walletControllerProvider.notifier) as ChartTestWallet;
      controller.replace([Transaction(time: '2026-11-09', moneyAmount: -123)]);
      await tester.pump();
      expect(
        tester.widget<LineGraph>(find.byType(LineGraph)).data.first.value,
        123,
      );
      container
          .read(localeProvider.notifier)
          .setLocale(const Locale('zh', 'CN'));
      await tester.pump();
      expect(find.text('每日交易总额 (\$)'), findsOneWidget);
      expect(
        tester.widget<LineGraph>(find.byType(LineGraph)).data.first.label,
        '周一',
      );
      await tester.pumpWidget(const SizedBox());
      container.dispose();
    },
  );

  testWidgets('narrow large text, empty, zero, loading and errors', (
    tester,
  ) async {
    final container = await pumpChart(tester, width: 260, scale: 2);
    final controller =
        container.read(walletControllerProvider.notifier) as ChartTestWallet;
    controller.replace([]);
    await tester.pump();
    expect(find.byKey(const ValueKey('home-chart-empty')), findsOneWidget);
    expect(tester.takeException(), isNull);
    controller.replace([Transaction(time: 'Today', moneyAmount: 0)]);
    await tester.pump();
    expect(find.text('All daily transaction amounts are zero'), findsOneWidget);
    controller.loading();
    await tester.pump();
    expect(find.byKey(const ValueKey('home-chart-loading')), findsOneWidget);
    expect(find.byType(LineGraph), findsNothing);
    controller.fail();
    await tester.pump();
    expect(find.text('Failure'), findsOneWidget);
    expect(find.byType(LineGraph), findsNothing);
    await tester.pumpWidget(const SizedBox());
    container.dispose();
  });
}
