import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';

class _TestLocaleNotifier extends LocaleNotifier {
  @override
  Locale build() => AppLocale.currentLocale;

  @override
  void setLocale(Locale locale) {
    AppLocale.setLocale(locale);
    state = locale;
  }
}

class _EmptyWalletController extends WalletController {
  @override
  WalletState build() => const WalletState(
    moneyTypes: [],
    selectedMonth: '',
    monthEnglishNameList: [],
    allTransactions: [],
    cards: [],
  );
}

void main() {
  late Locale originalLocale;
  setUp(() {
    originalLocale = AppLocale.currentLocale;
    AppLocale.setLocale(const Locale('zh', 'CN'));
  });
  tearDown(() => AppLocale.setLocale(originalLocale));

  testWidgets('首页空状态、交易摘要和本地示例随中英文切换', (tester) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith(_TestLocaleNotifier.new),
        walletControllerProvider.overrideWith(_EmptyWalletController.new),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(localeProvider),
            supportedLocales: AppLocale.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    HomeBankCardCarousel(),
                    HomeSummaryCards(),
                    HomeTransactionsPanel(),
                    HomeArticlesPanel(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    const chinese = [
      '暂无卡片，请前往钱包添加',
      '最近交易',
      '暂无交易记录',
      '转出',
      '转入',
      '交易摘要',
      '本地示例',
    ];
    const english = [
      'No cards yet. Add a card in Wallet.',
      'Transactions',
      'No transactions yet',
      'Money Out',
      'Money In',
      'Transaction summary',
      'Local examples',
    ];
    for (final text in chinese) {
      expect(find.text(text), findsOneWidget);
    }
    container.read(localeProvider.notifier).setLocale(const Locale('en', 'US'));
    await tester.pumpAndSettle();
    for (final text in english) {
      expect(find.text(text), findsOneWidget);
    }
    for (final text in chinese) {
      expect(find.text(text), findsNothing);
    }
    expect(find.text('Money Recharge'), findsNothing);
    container.read(localeProvider.notifier).setLocale(const Locale('zh', 'CN'));
    await tester.pumpAndSettle();
    for (final text in chinese) {
      expect(find.text(text), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('首页UI文案使用分域词条且不包含硬编码字符串', () {
    final source = File('lib/features/home/presentation/home_page.dart')
        .readAsStringSync();
    final ui = source.split('class HomeTabViewListItemWidget').first;
    expect(ui, isNot(contains("languageCode == 'zh'")));
    expect(
      ui,
      isNot(matches(RegExp("['\"][^'\"\\n]*[\\u4e00-\\u9fff][^'\"\\n]*['\"]"))),
    );
    for (final text in [
      'No cards yet.',
      'No transactions yet',
      'Money Send',
      'Money Recharge',
      'Transaction summary',
      'Local examples',
    ]) {
      expect(ui, isNot(contains(text)));
    }
    for (final key in [
      'home.noCardsInWallet',
      'home.recentTransactions',
      'home.transactionSummary',
      'home.localExamples',
      'wallet.noTransactions',
      'wallet.outgoing',
      'wallet.incoming',
    ]) {
      expect(ui, contains('Languages.$key'));
    }
    expect(source, contains('article.title(zh)'));
    expect(source, contains('article.summary(zh)'));
  });
}
