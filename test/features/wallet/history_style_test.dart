import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/wallet/presentation/history_page.dart';

class HistoryStyleController extends WalletController {
  @override
  WalletState build() => WalletState(
    moneyTypes: const ['Send', 'Receive', 'Total'],
    selectedMonth: 'November',
    monthEnglishNameList: const ['November'],
    referenceDate: DateTime(2026, 11, 10),
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
      Transaction(
        moneyActionName: 'An unusually long English transaction description that must grow without clipping the amount',
        moneyAmount: -1234567.89,
        time: '2026-10-01',
      ),
      Transaction(
        moneyActionName: 'Undated',
        moneyAmount: 10,
        time: 'Unknown date',
      ),
    ],
  );
}

Future<void> mountHistory(
  WidgetTester tester,
  double width,
  double scale,
  bool dark,
) async {
  tester.view.physicalSize = Size(width, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        walletControllerProvider.overrideWith(HistoryStyleController.new),
      ],
      child: MaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const Scaffold(body: HistoryPage()),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  for (final width in [390.0, 799.0, 800.0, 1100.0]) {
    for (final scale in [1.0, 2.0]) {
      for (final dark in [false, true]) {
        testWidgets('history style $width text $scale dark $dark', (
          tester,
        ) async {
          await mountHistory(tester, width, scale, dark);
          expect(tester.takeException(), isNull);
          expect(
            find.byKey(const ValueKey('history-segments')),
            findsOneWidget,
          );
          expect(find.byType(ChoiceChip), findsNothing);
          final totalBounds = tester.getRect(
            find.byKey(const ValueKey('history-total')),
          );
          final filtersBounds = tester.getRect(
            find.byKey(const ValueKey('history-segments')),
          );
          final searchBounds = tester.getRect(
            find.byKey(const ValueKey('history-search')),
          );
          final listBounds = tester.getRect(
            find.byKey(const ValueKey('history-transaction-container')),
          );
          expect(filtersBounds.top, greaterThan(totalBounds.bottom));
          expect(searchBounds.top, greaterThan(filtersBounds.bottom));
          expect(listBounds.top, greaterThan(searchBounds.bottom));
          expect(find.text('Search transactions'), findsOneWidget);
          expect(find.text('− \$ 1234567.89'), findsOneWidget);
          final amount = tester.widget<Text>(find.text('− \$ 1234567.89'));
          final context = tester.element(find.byType(HistoryPage));
          expect(amount.style!.color, AppColors.expense(context));
          expect(
            tester.getSize(find.text('− \$ 1234567.89')).height,
            greaterThan(0),
          );
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }

  testWidgets('history filters and search update actual total and zero bars', (
    tester,
  ) async {
    await mountHistory(tester, 1100, 1, false);
    expect(find.text('\$ 1234697.89'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('history-period-1')));
    await tester.pump();
    expect(find.text('Salary'), findsNothing);
    expect(find.text('Undated'), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('history-total'))).data,
      '\$ 20.00',
    );
    expect(find.byKey(const ValueKey('bar-0-20.0')), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Salary');
    await tester.pump();
    expect(find.text('\$ 0.00'), findsOneWidget);
    for (var i = 0; i < 7; i++) {
      expect(tester.getSize(find.byKey(ValueKey('bar-$i-0.0'))).height, 0);
    }
    await tester.tap(find.byKey(const ValueKey('history-period-2')));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('history-total'))).data,
      '\$ 100.00',
    );
    expect(
      find
          .text('Salary', findRichText: false)
          .evaluate()
          .where((element) => element.widget is Text),
      hasLength(1),
    );
    expect(find.byType(Hero), findsOneWidget);
    expect(
      tester.widget<Hero>(find.byType(Hero)).tag,
      startsWith('hero_history_'),
    );
    expect(tester.takeException(), isNull);
  });
}
