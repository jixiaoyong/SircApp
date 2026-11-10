import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/widgets/jingang_widget.dart';
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

  testWidgets('全部15个快捷入口含翻页随中英中切换且原始标题不变', (tester) async {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith(_TestLocaleNotifier.new),
        walletControllerProvider.overrideWith(_EmptyWalletController.new),
      ],
    );
    addTearDown(container.dispose);
    final original = container
        .read(homeControllerProvider)
        .quickActions
        .map((action) => action.title)
        .toList();
    const chinese = [
      '债券',
      '账单',
      '现金',
      '钱袋',
      '钱包',
      '退票',
      '税务',
      '采购订单',
      '付款记录',
      '用卡',
      '卡片安全',
      '卡片正面',
      '卡片遗失',
      '信用管理',
      '商品',
    ];
    final english = [...original]
      ..[11] = 'Card Front Side'
      ..[12] = 'Card Missing';
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(localeProvider),
            supportedLocales: AppLocale.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeTopBodyWidget(
                  homeState: container
                      .read(homeControllerProvider)
                      .copyWith(
                        quickActions: [
                          for (final title in original) ImgText('', title),
                        ],
                      ),
                  userAvatar: '',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final grid = find.byWidgetPredicate((widget) => widget is JingangWidget);
    final pages = find.descendant(of: grid, matching: find.byType(PageView));
    final controller = tester.widget<PageView>(pages).controller!;
    for (final language in ['zh', 'en', 'zh']) {
      container.read(localeProvider.notifier).setLocale(Locale(language));
      await tester.pumpAndSettle();
      final expected = language == 'zh' ? chinese : english;
      controller.jumpToPage(0);
      await tester.pumpAndSettle();
      for (final text in expected.take(12)) {
        expect(
          find.descendant(of: grid, matching: find.text(text)),
          findsOneWidget,
        );
      }
      await tester.drag(pages, const Offset(-350, 0));
      await tester.pumpAndSettle();
      expect(controller.page, closeTo(1, .01));
      for (final text in expected.skip(12)) {
        expect(
          find.descendant(of: grid, matching: find.text(text)),
          findsOneWidget,
        );
      }
      expect(
        container
            .read(homeControllerProvider)
            .quickActions
            .map((action) => action.title)
            .toList(),
        original,
      );
      expect(tester.takeException(), isNull);
    }
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
