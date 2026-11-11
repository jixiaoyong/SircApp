import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';
import 'package:sirc/features/wallet/presentation/history_page.dart';
import 'package:sirc/features/wallet/presentation/transaction_detail_page.dart';
import 'package:sirc/features/home/presentation/person_page.dart';

class TestWalletController extends WalletController {
  @override
  WalletState build() => WalletState(
    moneyTypes: const ['Send', 'Receive', 'Total'],
    selectedMonth: 'January',
    monthEnglishNameList: const ['January'],
    referenceDate: DateTime(2026, 11, 10),
    cards: const [
      BankCard(
        id: '1',
        bankName: 'Test',
        cardNumber: '1111222233334444',
        ownerName: 'User',
        expirationDate: '12/29',
      ),
    ],
    allTransactions: [
      Transaction(
        moneyActionName: 'Coffee',
        moneyAmount: -20,
        time: '2026-11-09',
      ),
      Transaction(
        moneyActionName: 'Salary',
        moneyAmount: 100,
        time: '2026-11-01',
      ),
      Transaction(moneyActionName: 'Old', moneyAmount: -30, time: '2026-10-01'),
      Transaction(
        moneyActionName: 'Undated',
        moneyAmount: 10,
        time: 'Just now',
      ),
    ],
  );
}

void main() {
  testWidgets(
    'chart has narrow proportional bars, no tracks and honest zeros',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WalletBars(values: [0, 0, 0, 0, 0, 0, 0])),
        ),
      );
      for (var i = 0; i < 7; i++) {
        expect(find.byKey(ValueKey('wallet-bar-track-$i')), findsNothing);
        expect(tester.getSize(find.byKey(ValueKey('bar-$i-0.0'))).height, 0);
      }
      expect(find.byKey(const ValueKey('wallet-chart-empty')), findsOneWidget);
      expect(
        find.text('No records to summarize in the selected range'),
        findsOneWidget,
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WalletBars(values: [1, 2, 3, 4, 5, 6, 7])),
        ),
      );
      for (var i = 0; i < 7; i++) {
        expect(
          tester.getSize(find.byKey(ValueKey('bar-$i-${i + 1}.0'))).height,
          greaterThan(0),
        );
      }
      expect(find.byKey(const ValueKey('wallet-chart-empty')), findsNothing);
      final first = tester.getSize(find.byKey(const ValueKey('bar-0-1.0')));
      final last = tester.getSize(find.byKey(const ValueKey('bar-6-7.0')));
      expect(last.width, lessThanOrEqualTo(28));
      expect(first.height / last.height, closeTo(1 / 7, .001));
      final bar = tester.widget<Container>(
        find.byKey(const ValueKey('bar-0-1.0')),
      );
      expect((bar.decoration! as BoxDecoration).border, isNull);
    },
  );

  testWidgets('carousel supports arrows, swipes, additions, single and empty', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var selected = 0;
    var cards = List.generate(
      3,
      (i) => BankCard(
        id: '$i',
        bankName: 'Bank $i',
        cardNumber: '1111222233334444',
        ownerName: 'User',
        expirationDate: '12/29',
      ),
    );
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return WalletCardCarousel(
                cards: cards,
                selectedIndex: selected,
                onSelected: (index) => setState(() => selected = index),
              );
            },
          ),
        ),
      ),
    );
    expect(find.text('1 / 3'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('wallet-card-next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(selected, 1);
    expect(find.text('2 / 3'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('wallet-cards')),
      const Offset(-320, 0),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(selected, 2);
    update(() => cards = [...cards, cards.first]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('3 / 4'), findsOneWidget);
    update(() {
      cards = [cards.first];
      selected = 0;
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('wallet-card-next')), findsNothing);
    expect(find.byKey(const ValueKey('wallet-card-count')), findsNothing);
    update(() => cards = []);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('wallet-cards')), findsNothing);
    expect(find.textContaining('No cards yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final dark in [false, true]) {
    testWidgets(
      'wallet transaction long content and amount at 320, scale 2, dark $dark',
      (tester) async {
        tester.view.physicalSize = const Size(320, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: dark ? Brightness.dark : Brightness.light,
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: WalletTransactionList(
                  heroPrefix: 'test-',
                  designStyle: true,
                  items: [
                    Transaction(
                      moneyActionName: 'A very long merchant name with a detailed payment description',
                      time: '2026-11-10T12:30:00',
                      moneyAmount: -123456789.99,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('− \$ 123456789.99'), findsOneWidget);
      },
    );
  }
  for (final width in [390.0, 815.0, 816.0, 839.0, 840.0, 1100.0]) {
    for (final scale in [1.0, 2.0]) {
      for (final page in [
        const WalletPage(),
        const HistoryPage(),
        const PersonPage(),
        TransactionDetailPage(
          data: Transaction(
            moneyAmount: -20,
            moneyActionName: 'Coffee',
            time: '2026-11-09',
          ),
          heroTag: 'source',
        ),
      ]) {
        testWidgets('${page.runtimeType} width $width scale $scale', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 1600);
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
                home: Scaffold(body: page),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
          if (page is WalletPage) {
            final listBounds = tester.getRect(
              find.byKey(const ValueKey('wallet-transactions')),
            );
            final statsBounds = tester.getRect(
              find.byKey(const ValueKey('wallet-statistics')),
            );
            final cardsBounds = tester.getRect(
              find.byKey(const ValueKey('wallet-cards')),
            );
            final balanceBounds = tester.getRect(
              find.byKey(const ValueKey('wallet-balance')),
            );
            final cardPanelBounds = tester.getRect(
              find.byKey(const ValueKey('wallet-card-panel')),
            );
            final contentWidth = width.clamp(0, 1017) - 56;
            if (contentWidth >= 760 && 14 * scale < 24) {
              expect(cardPanelBounds.top, closeTo(balanceBounds.top, .01));
              expect(
                cardPanelBounds.left - balanceBounds.right,
                closeTo(16, .01),
              );
              expect(
                balanceBounds.width,
                closeTo((contentWidth - 16) / 2, .01),
              );
              expect(cardPanelBounds.width, closeTo(balanceBounds.width, .01));
            } else {
              expect(
                cardPanelBounds.top - balanceBounds.bottom,
                closeTo(16, .01),
              );
              expect(balanceBounds.width, closeTo(contentWidth, .01));
              expect(cardPanelBounds.width, closeTo(contentWidth, .01));
            }
            expect(statsBounds.top, greaterThan(balanceBounds.bottom));
            expect(statsBounds.top, greaterThan(cardPanelBounds.bottom));
            expect(listBounds.top, greaterThan(statsBounds.bottom));
            expect(listBounds.top, greaterThan(cardsBounds.bottom));
            expect(listBounds.width, closeTo(width.clamp(0, 1017) - 56, 1));
          }
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }
  testWidgets('history date, search, total and bars share the real selection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(840, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletControllerProvider.overrideWith(TestWalletController.new),
        ],
        child: const MaterialApp(home: Scaffold(body: HistoryPage())),
      ),
    );
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('\$ 160.00'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('history-period-1')));
    await tester.pump();
    expect(find.text('Salary'), findsNothing);
    expect(find.text('Undated'), findsOneWidget);
    expect(find.text('\$ 30.00'), findsOneWidget);
    expect(find.byKey(const ValueKey('bar-0-20.0')), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Salary');
    await tester.pump();
    expect(find.text('\$ 0.00'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('history-period-2')));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('history-total'))).data,
      '\$ 100.00',
    );
    expect(find.byKey(const ValueKey('bar-6-100.0')), findsOneWidget);
  });
  testWidgets('wallet send and receive update totals and records', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletControllerProvider.overrideWith(TestWalletController.new),
        ],
        child: const MaterialApp(home: Scaffold(body: WalletPage())),
      ),
    );
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.byIcon(Icons.check), findsNothing);
    final segment = tester.widget<TextButton>(
      find.byKey(const ValueKey('wallet-filter-0')),
    );
    expect(segment.style!.foregroundColor!.resolve({}), isNot(Colors.blue));
    expect(find.textContaining('Device date;'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('wallet-filter-1')));
    await tester.pump();
    expect(find.text('Coffee'), findsNothing);
    expect(find.text('Salary'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('wallet-total'))).data,
      '+ \$ 10.00',
    );
    await tester.tap(find.byKey(const ValueKey('wallet-filter-2')));
    await tester.pump();
    expect(find.text('\$ 30.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
