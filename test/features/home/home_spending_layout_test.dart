import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/presentation/widgets/home_articles_panel.dart';
import 'package:sirc/mock/mock_data_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/features/home/data/article_repository.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/features/home/presentation/article_detail_page.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/routes/app_routes.dart';
import 'package:sirc/utils/date_time_formatter.dart';

class _SummaryWalletController extends WalletController {
  @override
  WalletState build() => WalletState(
    moneyTypes: const [],
    selectedMonth: '',
    monthEnglishNameList: const [],
    allTransactions: [
      Transaction(
        moneyActionName: 'Expense',
        moneyAmount: -888.65,
        time: '2026-11-07',
      ),
      Transaction(
        moneyActionName: 'Income',
        moneyAmount: 5234.81,
        time: '2026-11-06',
      ),
    ],
  );
}

class _HomeWalletController extends WalletController {
  @override
  WalletState build() => WalletState(
    moneyTypes: const [],
    selectedMonth: '',
    monthEnglishNameList: const [],
    allTransactions: [
      Transaction(
        moneyActionName: 'A long outgoing transaction description',
        moneyAmount: -20,
        time: '2026-11-09',
      ),
      Transaction(
        moneyActionName: 'Salary',
        moneyAmount: 100,
        time: '2026-11-08',
      ),
      Transaction(
        moneyActionName: 'Large expense',
        moneyAmount: -888.65,
        time: '2026-11-07',
      ),
      Transaction(
        moneyActionName: 'Large income',
        moneyAmount: 5234.81,
        time: '2026-11-06',
      ),
    ],
  );
}

void main() {
  late MockDataRepository mock;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mock = MockDataRepository();
    await mock.articles;
  });
  setUp(() => AppLocale.setLocale(const Locale('en', 'US')));
  Widget withRepository(Widget child) => ProviderScope(
    overrides: [mockDataRepositoryProvider.overrideWithValue(mock)],
    child: child,
  );
  test('Repository 返回唯一文章集合，并按Locale映射且详情ID稳定', () async {
    final zhGroups = await mock.getArticleGroups(const Locale('zh'));
    final enGroups = await mock.getArticleGroups(const Locale('en'));
    final chinese = await ArticleRepository(mock).getGroups(const Locale('zh'));
    final english = await ArticleRepository(mock).getGroups(const Locale('en'));
    final zhArticles = chinese.expand((group) => group).toList();
    final enArticles = english.expand((group) => group).toList();

    expect(zhArticles, hasLength(72));
    expect(enArticles, hasLength(72));
    expect(zhArticles.first.title, zhGroups.first.first['title']);
    expect(enArticles.first.title, enGroups.first.first['title']);
    expect(zhArticles.first.title, '认识债券');
    expect(enArticles.first.title, 'Bonds');
    expect(
      (await ArticleRepository(mock).getById('0-0', const Locale('en')))?.body,
      contains('A bond usually specifies'),
    );
    expect(
      await ArticleRepository(mock).getById('99-99', const Locale('zh')),
      isNull,
    );
    expect(
      await ArticleRepository(mock).getById('bad', const Locale('zh')),
      isNull,
    );
  });
  test('72篇文章拥有独立标题、摘要、正文与有效ID', () async {
    final chinese = await ArticleRepository(mock).getGroups(const Locale('zh'));
    final english = await ArticleRepository(mock).getGroups(const Locale('en'));
    for (final articles in [
      chinese.expand((group) => group).toList(),
      english.expand((group) => group).toList(),
    ]) {
      expect(articles, hasLength(72));
      expect(articles.map((e) => e.title).toSet(), hasLength(72));
      expect(articles.map((e) => e.summary).toSet(), hasLength(72));
      expect(articles.map((e) => e.body).toSet(), hasLength(72));
    }
    expect(
      await ArticleRepository(mock).getById('0-24', const Locale('zh')),
      isNull,
    );
    expect(
      await ArticleRepository(mock).getById('bad', const Locale('zh')),
      isNull,
    );
  });
  for (final language in ['zh', 'en']) {
    testWidgets('窄屏交易摘要金额完整单行 $language', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      AppLocale.setLocale(
        language == 'zh' ? const Locale('zh', 'CN') : const Locale('en', 'US'),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletControllerProvider.overrideWith(_SummaryWalletController.new),
          ],
          child: MaterialApp(
            locale: Locale(language),
            supportedLocales: AppLocale.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: HomeSummaryCards(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final expense = tester.widget<Text>(
        find.byKey(const ValueKey('home-summary-amount-0')),
      );
      final income = tester.widget<Text>(
        find.byKey(const ValueKey('home-summary-amount-1')),
      );
      expect(expense.maxLines, 1);
      expect(expense.softWrap, isFalse);
      expect(income.maxLines, 1);
      expect(income.softWrap, isFalse);
      expect(expense.data, contains('888.65'));
      expect(income.data, contains('5.23K'));
      expect(expense.data, startsWith('−'));
      expect(income.data, startsWith('+'));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  for (final width in [390.0, 1100.0]) {
    testWidgets('文章纵向列表与18篇独立详情 width $width 大字', (tester) async {
      tester.view.physicalSize = Size(width, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: '/main',
        routes: [
          GoRoute(
            path: '/main',
            builder: (_, _) => const Scaffold(
              body: CustomScrollView(slivers: [HomeArticlesPanel()]),
            ),
            routes: [
              GoRoute(
                path: 'article/:id',
                builder: (_, state) =>
                    ArticleDetailPage(id: state.pathParameters['id']!),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        withRepository(
          MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final articleGroups = await mock.getArticleGroups(const Locale('en'));
      for (var group = 0; group < articleGroups.length; group++) {
        await tester.ensureVisible(
          find.byKey(ValueKey('article-segment-$group')),
        );
        await tester.tap(find.byKey(ValueKey('article-segment-$group')));
        await tester.pumpAndSettle();
        for (var index = 0; index < articleGroups[group].length; index++) {
          final item = find.byKey(ValueKey('home-article-$group-$index'));
          final rect = tester.getRect(item);
          if (index > 0) {
            final previous = tester.getRect(
              find.byKey(ValueKey('home-article-$group-${index - 1}')),
            );
            expect(rect.top, greaterThanOrEqualTo(previous.bottom));
            expect(rect.width, closeTo(previous.width, 1));
          }
          await tester.ensureVisible(item);
          await tester.tap(item);
          await tester.pumpAndSettle();
          final article = await mock.getArticleById(
            '$group-$index',
            const Locale('en'),
          );
          expect(find.text(article!['body'] as String), findsOneWidget);
          expect(find.text(Languages.home.articleDisclaimer), findsNothing);
          expect(
            find.text(
              AppDateTimeFormatter.display(
                article['publishedAt'] as String,
                locale: const Locale('en'),
                languages: AppLocale.current,
              ),
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          router.pop();
          await tester.pumpAndSettle();
        }
      }
      await tester.pumpWidget(const SizedBox());
    });
  }

  for (final width in [390.0, 600.0, 1200.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('完整首页局部宽$width 字体$scale区域顺序与透明状态栏', (tester) async {
        // 真实窗口高度须留出足够滚动范围跨过吸顶阈值（宽屏短文章尤其如此）。
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              mockDataRepositoryProvider.overrideWithValue(mock),
              walletControllerProvider.overrideWith(_HomeWalletController.new),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const Scaffold(body: HomePage()),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();
        final graph = tester.getRect(
          find.byKey(const ValueKey('home-weekly-graph')),
        );
        final summary = tester.getRect(find.byType(HomeSummaryCards));
        final transactions = tester.getRect(
          find.byKey(const ValueKey('home-transactions')),
        );
        final cards = tester.getRect(find.byType(HomeBankCardCarousel));
        final gutter = 16 + 16 * ((width - 320) / 240).clamp(0.0, 1.0);
        final expectedContentWidth = width - gutter * 2;
        expect(cards.width, closeTo(expectedContentWidth, 1));
        final activityHeading = find.byKey(
          const ValueKey('home-activity-heading'),
        );
        final summaryHeading = find.byKey(
          const ValueKey('home-summary-heading'),
        );
        final transactionsHeading = find.byKey(
          const ValueKey('home-transactions-heading'),
        );
        for (final heading in [
          activityHeading,
          summaryHeading,
          transactionsHeading,
        ]) {
          final text = tester.widget<Text>(heading);
          expect(text.style!.fontSize, 16);
          expect(text.style!.fontWeight, FontWeight.w600);
        }
        expect(tester.getRect(activityHeading).left, closeTo(gutter, .01));
        expect(tester.getRect(summaryHeading).left, closeTo(summary.left, .01));
        expect(tester.getRect(transactionsHeading).left, closeTo(gutter, .01));
        expect(
          tester.getRect(find.byKey(const ValueKey('home-summary-0'))).top -
              tester.getRect(summaryHeading).bottom,
          closeTo(12, .01),
        );
        if (width == 1200 && scale == 1) {
          expect(summary.top, graph.top);
          expect(summary.left, greaterThan(graph.right));
        } else {
          expect(summary.top - graph.bottom, closeTo(18, .01));
        }
        expect(transactions.width, closeTo(expectedContentWidth, 1));
        expect(find.byKey(const ValueKey('home-avatar')), findsOneWidget);
        final avatarBefore = tester.getRect(
          find.byKey(const ValueKey('home-avatar')),
        );
        await tester.drag(
          find.byType(CustomScrollView).first,
          const Offset(0, -600),
        );
        await tester.pump(const Duration(seconds: 1));
        final avatarScrolled = tester.getRect(
          find.byKey(const ValueKey('home-avatar')),
        );
        expect(avatarScrolled.width, closeTo(34.0, .5));
        expect(avatarScrolled.height, closeTo(34.0, .5));
        expect(avatarScrolled.top, lessThan(avatarBefore.top));
        // 在完整首页验证外层纵向滚动，而非银行卡横向 ScrollController。
        final scrollView = find.byType(CustomScrollView).first;
        final position = tester
            .state<ScrollableState>(
              find
                  .descendant(of: scrollView, matching: find.byType(Scrollable))
                  .first,
            )
            .position;
        final segment = find.byKey(const ValueKey('article-segment-1'));
        // Sliver 子项接近视口前不会构建，先按真实滚动推进到分类栏附近。
        while (segment.evaluate().isEmpty &&
            position.pixels < position.maxScrollExtent) {
          position.jumpTo(
            (position.pixels + position.viewportDimension * .8).clamp(
              0.0,
              position.maxScrollExtent,
            ),
          );
          await tester.pump();
        }
        expect(segment, findsOneWidget);
        final articlesHeading = find.byKey(
          const ValueKey('home-articles-heading'),
        );
        final articleTitle = tester.widget<Text>(articlesHeading);
        expect(articleTitle.style!.fontSize, 16);
        expect(articleTitle.style!.fontWeight, FontWeight.w600);
        expect(tester.getRect(articlesHeading).left, closeTo(gutter, .01));
        final viewport = tester.getRect(scrollView);
        final threshold =
            position.pixels + tester.getRect(segment).top - viewport.top;
        expect(position.maxScrollExtent, greaterThan(threshold + 100));
        position.jumpTo(threshold + 100);
        await tester.pump();
        await tester.pump();
        expect(
          tester.getRect(segment).top,
          closeTo(viewport.top + tester.view.padding.top + 4, .5),
        );
        final avatarSticky = tester.getRect(
          find.byKey(const ValueKey('home-avatar')),
        );
        expect(avatarSticky.width, closeTo(34.0, .5));
        expect(avatarSticky.height, closeTo(34.0, .5));
        expect(avatarSticky.top, lessThan(avatarBefore.top));
        await tester.tap(find.byKey(const ValueKey('article-segment-2')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byKey(const ValueKey('home-article-2-0')), findsOneWidget);
        final overlays = tester
            .widgetList<AnnotatedRegion<SystemUiOverlayStyle>>(
              find.byWidgetPredicate(
                (w) => w is AnnotatedRegion<SystemUiOverlayStyle>,
              ),
            );
        expect(
          overlays.any((w) => w.value.statusBarColor == Colors.transparent),
          isTrue,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('首页交易 $width dark=$dark scale=$scale 无溢出且可操作', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 1600);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final router = GoRouter(
            initialLocation: '/main',
            routes: [
              GoRoute(
                path: '/main',
                builder: (_, _) => const Scaffold(
                  body: SingleChildScrollView(child: HomeTransactionsPanel()),
                ),
              ),
              GoRoute(
                path: AppRoutes.HISTORY,
                builder: (_, _) =>
                    const Scaffold(body: Text('history destination')),
              ),
              GoRoute(
                path: '/main/${AppRoutes.TRANSACTION_SEGMENT}',
                builder: (_, state) => Scaffold(
                  body: Text(
                    (state.extra as Map)['data'].moneyActionName as String,
                  ),
                ),
              ),
            ],
          );
          addTearDown(router.dispose);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                walletControllerProvider.overrideWith(
                  _HomeWalletController.new,
                ),
              ],
              child: MaterialApp.router(
                routerConfig: router,
                theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
              ),
            ),
          );
          await tester.pump();
          final amount = find.text('+ \$ 100.00');
          expect(amount, findsOneWidget);
          expect(
            tester.widget<Text>(amount).style!.color,
            AppColors.income(tester.element(amount)),
          );
          expect(find.text('− \$ 20.00'), findsOneWidget);
          // 首页仅展示前三笔交易，分隔线应恰好位于三行之间。
          expect(
            find.byKey(const ValueKey('home-transaction-2')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('home-transaction-3')),
            findsNothing,
          );
          expect(find.byType(Divider), findsNWidgets(2));
          final row = find.byKey(const ValueKey('home-transaction-1'));
          final bounds = tester.getRect(row);
          final amountBounds = tester.getRect(amount);
          expect(amountBounds.right, lessThanOrEqualTo(bounds.right));
          if (scale == 1) {
            expect(amountBounds.right, closeTo(bounds.right - 14, 1));
          }
          expect(amountBounds.bottom, lessThanOrEqualTo(bounds.bottom));
          expect(tester.takeException(), isNull);
          await tester.tap(row);
          await tester.pumpAndSettle();
          expect(find.text('Salary'), findsOneWidget);
          router.pop();
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('home-all-transactions')));
          await tester.pumpAndSettle();
          expect(find.text('history destination'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
  testWidgets('文章卡片展示明确的本地设计示例', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      withRepository(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CustomScrollView(slivers: [HomeArticlesPanel()]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final article = await mock.getArticleById('0-0', const Locale('en'));
    expect(find.text(article!['title'] as String), findsOneWidget);
    expect(find.text(article['summary'] as String), findsOneWidget);
    expect(find.text('Article content coming soon'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
