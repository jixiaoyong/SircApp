import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/core/theme/app_colors.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/features/home/presentation/sample_articles.dart';
import 'package:sirc/features/home/presentation/article_detail_page.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/routes/app_routes.dart';

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
    ],
  );
}

void main() {
  test('18篇文章拥有独立标题、摘要、正文与有效ID', () {
    final articles = sampleArticleGroups.expand((group) => group).toList();
    expect(articles, hasLength(18));
    for (final zh in [false, true]) {
      expect(articles.map((e) => e.title(zh)).toSet(), hasLength(18));
      expect(articles.map((e) => e.summary(zh)).toSet(), hasLength(18));
      expect(articles.map((e) => e.body(zh)).toSet(), hasLength(18));
    }
    expect(sampleArticleForId('0-6'), isNull);
    expect(sampleArticleForId('bad'), isNull);
  });
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
              body: SingleChildScrollView(child: HomeArticlesPanel()),
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
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var group = 0; group < 3; group++) {
        await tester.ensureVisible(
          find.byKey(ValueKey('article-segment-$group')),
        );
        await tester.tap(find.byKey(ValueKey('article-segment-$group')));
        await tester.pumpAndSettle();
        for (var index = 0; index < 6; index++) {
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
          final article = sampleArticleForId('$group-$index')!;
          expect(find.text(article.bodyEn), findsOneWidget);
          expect(find.textContaining('Static example'), findsOneWidget);
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
        tester.view.physicalSize = Size(width, 2000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
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
        final graph = tester.getRect(
          find.byKey(const ValueKey('home-weekly-graph')),
        );
        final summary = tester.getRect(find.byType(HomeSummaryCards));
        final transactions = tester.getRect(
          find.byKey(const ValueKey('home-transactions')),
        );
        final articles = tester.getRect(
          find.byKey(const ValueKey('home-articles')),
        );
        final cards = tester.getRect(find.byType(HomeBankCardCarousel));
        expect(cards.width, width - 40);
        if (width == 1200 && scale == 1) {
          expect(summary.top, graph.top);
          expect(summary.left, greaterThan(graph.right));
        } else {
          expect(summary.top, greaterThanOrEqualTo(graph.bottom));
        }
        expect(transactions.width, width - 40);
        expect(articles.width, transactions.width);
        expect(articles.top, greaterThanOrEqualTo(transactions.bottom));
        expect(find.byKey(const ValueKey('home-avatar')), findsOneWidget);
        final avatarBefore = tester.getRect(
          find.byKey(const ValueKey('home-avatar')),
        );
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -600),
        );
        await tester.pump(const Duration(seconds: 1));
        expect(
          tester.getRect(find.byKey(const ValueKey('home-avatar'))),
          avatarBefore,
        );
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
          expect(find.byType(Divider), findsOneWidget);
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
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: HomeTabViewListItemWidget(tabTitle: 'Follow', index: 0),
        ),
      ),
    );
    expect(find.text('Bonds'), findsOneWidget);
    expect(find.text('Understand assets and risk'), findsOneWidget);
    expect(find.text('Article content coming soon'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
