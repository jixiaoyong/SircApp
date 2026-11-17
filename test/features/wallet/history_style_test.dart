import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/widgets/page_gutter.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/features/wallet/presentation/history_page.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';

class _HistoryLocaleNotifier extends LocaleNotifier {
  _HistoryLocaleNotifier(this.locale);
  final Locale locale;

  @override
  Locale build() {
    AppLocale.setLocale(locale);
    return locale;
  }
}

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
        localeProvider.overrideWith(
          () => _HistoryLocaleNotifier(AppLocale.currentLocale),
        ),
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
  setUpAll(() => initializeDateFormatting());
  for (final locale in [const Locale('en'), const Locale('zh')]) {
    testWidgets('history calendar labels and search ${locale.languageCode}', (
      tester,
    ) async {
      AppLocale.setLocale(locale);
      addTearDown(() => AppLocale.setLocale(const Locale('en')));
      await mountHistory(tester, 390, 2, false);
      var bars = tester.widget<WalletBars>(find.byType(WalletBars));
      expect(bars.values, [...List<double>.filled(9, 0), 1234567.89, 120]);
      expect(bars.labels, [
        for (var month = 1; month <= 11; month++)
          '2026-${month.toString().padLeft(2, '0')}',
      ]);
      expect(find.text('2026-10'), findsOneWidget);
      expect(find.text(Languages.wallet.filterByDate), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('history-period-2')));
      await tester.pump();
      bars = tester.widget<WalletBars>(find.byType(WalletBars));
      expect(bars.values, hasLength(30));
      expect(bars.values[0], 100);
      expect(bars.values[8], 20);
      expect(bars.labels!.where((label) => label.isNotEmpty), [
        '1',
        '5',
        '10',
        '15',
        '20',
        '25',
        '30',
      ]);
      await tester.enterText(find.byType(TextFormField), 'Coffee');
      await tester.pump();
      bars = tester.widget<WalletBars>(find.byType(WalletBars));
      expect(bars.values.fold<double>(0, (sum, value) => sum + value), 20);
      expect(find.text('Salary'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('history-period-0')));
      await tester.pump();
      bars = tester.widget<WalletBars>(find.byType(WalletBars));
      expect(bars.values, [...List<double>.filled(10, 0), 20]);
      expect(bars.labels!.first, '2026-01');
      expect(bars.labels!.last, '2026-11');
      await tester.enterText(find.byType(TextFormField), 'absent');
      await tester.tap(find.byKey(const ValueKey('history-period-0')));
      await tester.pump();
      bars = tester.widget<WalletBars>(find.byType(WalletBars));
      expect(bars.values, isEmpty);
      expect(find.byKey(const ValueKey('wallet-chart-empty')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
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
          final chartBounds = tester.getRect(find.byType(WalletBars));
          expect(searchBounds.bottom, lessThanOrEqualTo(filtersBounds.top));
          expect(filtersBounds.bottom, lessThanOrEqualTo(totalBounds.top));
          expect(totalBounds.bottom, lessThanOrEqualTo(chartBounds.top));
          expect(chartBounds.bottom, lessThanOrEqualTo(listBounds.top));
          expect(find.text('Search transactions'), findsOneWidget);
          expect(find.text('− \$ 1.23M'), findsOneWidget);
          final amount = tester.widget<Text>(find.text('− \$ 1.23M'));
          final context = tester.element(find.byType(HistoryPage));
          expect(amount.style!.color, AppColors.expense(context));
          expect(
            tester.getSize(find.text('− \$ 1.23M')).height,
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

  testWidgets(
    'history filter segments expands to full width only when pinned on narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(390, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // 1. 窄屏未吸顶状态：具有 gutter 边距
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletControllerProvider.overrideWith(HistoryStyleController.new),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: HistoryPage()),
          ),
        ),
      );
      await tester.pump();

      final gutter = PageGutter.gutterFor(390.0);
      final unpinnedRect = tester.getRect(
        find.byKey(const ValueKey('history-segments')),
      );
      expect(unpinnedRect.left, closeTo(gutter, 0.001));
      expect(unpinnedRect.right, closeTo(390.0 - gutter, 0.001));
      expect(unpinnedRect.width, closeTo(390.0 - 2 * gutter, 0.001));

      // 2. 向上滚动使筛选器吸顶：窄屏下左右间距移除，占满全宽 390
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      final pinnedRect = tester.getRect(
        find.byKey(const ValueKey('history-segments')),
      );
      expect(pinnedRect.left, 0.0);
      expect(pinnedRect.right, 390.0);
      expect(pinnedRect.width, 390.0);

      // 3. 宽屏状态：吸顶时依然保留侧边边距
      tester.view.physicalSize = const Size(1000, 600);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletControllerProvider.overrideWith(HistoryStyleController.new),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: HistoryPage()),
          ),
        ),
      );
      await tester.pump();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      final widePinnedRect = tester.getRect(
        find.byKey(const ValueKey('history-segments')),
      );
      expect(widePinnedRect.left, greaterThan(0));
      expect(widePinnedRect.width, lessThan(1000.0));
    },
  );
}
