import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';

import 'wallet_widget_test.dart' show TestWalletController;

void expectVerticalStatistics(WidgetTester tester, double availableWidth) {
  final statistics = tester.getRect(
    find.byKey(const ValueKey('wallet-statistics')),
  );
  final transactions = tester.getRect(
    find.byKey(const ValueKey('wallet-transactions')),
  );
  final cards = tester.getRect(find.byKey(const ValueKey('wallet-cards')));
  expect(statistics.width, closeTo(availableWidth.clamp(0, 1017) - 56, 1));
  expect(transactions.width, closeTo(statistics.width, .01));
  expect(transactions.left, closeTo(statistics.left, .01));
  expect(statistics.top, greaterThan(cards.bottom));
  expect(transactions.top - statistics.bottom, closeTo(16, .01));
  expect(tester.takeException(), isNull);
}

void main() {
  for (final width in [390.0, 1100.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'statistics precede full-width records at $width scale $scale',
        (tester) async {
          tester.view.physicalSize = Size(width, 2400);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                walletControllerProvider.overrideWith(TestWalletController.new),
              ],
              child: MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: const Scaffold(body: WalletPage()),
              ),
            ),
          );
          expectVerticalStatistics(tester, width);
          final filters = [
            ('− \$ 20.00', ['Coffee', 'Old'], 'bar-0-20.0'),
            ('+ \$ 10.00', ['Salary', 'Undated'], 'bar-1-10.0'),
            ('\$ 30.00', ['Coffee', 'Salary', 'Old'], 'bar-0-20.0'),
          ];
          for (var index = 0; index < filters.length; index++) {
            final filter = find.byKey(ValueKey('wallet-filter-$index'));
            await tester.ensureVisible(filter);
            await tester.tap(filter);
            await tester.pump();
            final (total, records, barKey) = filters[index];
            expect(
              tester
                  .widget<Text>(find.byKey(const ValueKey('wallet-total')))
                  .data,
              total,
            );
            final list = tester.widget<WalletTransactionList>(
              find.byType(WalletTransactionList),
            );
            expect(list.items.map((item) => item.moneyActionName), records);
            expect(find.byKey(ValueKey(barKey)), findsOneWidget);
            expect(
              tester.getSize(find.byKey(ValueKey(barKey))).width,
              lessThanOrEqualTo(28),
            );
            expectVerticalStatistics(tester, width);
          }
        },
      );
    }
  }

  testWidgets('source pane shrink keeps statistics and records stacked', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late StateSetter resize;
    var showDetails = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletControllerProvider.overrideWith(TestWalletController.new),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                resize = setState;
                return Row(
                  children: [
                    const Expanded(child: WalletPage()),
                    if (showDetails) const SizedBox(width: 480),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
    expectVerticalStatistics(tester, 1100);
    resize(() => showDetails = true);
    await tester.pump();
    expectVerticalStatistics(tester, 620);
    resize(() => showDetails = false);
    await tester.pump();
    expectVerticalStatistics(tester, 1100);
  });
}
