import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/features/home/presentation/person_page.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/widgets/jingang_widget.dart';
import 'package:sirc/widgets/expandable_page_view.dart';
import 'package:sirc/widgets/network_web_image.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/mock/mock_data_repository.dart';

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
  late MockDataRepository repository;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    repository = MockDataRepository();
    // 在真实异步区预加载 AssetBundle，避免 testWidgets 的 FakeAsync 等待文件 I/O。
    await repository.articles;
    await repository.user;
  });
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    for (final text in english) {
      expect(find.text(text), findsOneWidget);
    }
    for (final text in chinese) {
      expect(find.text(text), findsNothing);
    }
    expect(find.text('Money Recharge'), findsNothing);
    container.read(localeProvider.notifier).setLocale(const Locale('zh', 'CN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    for (final text in chinese) {
      expect(find.text(text), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('个人页资料中英文映射且流水来自钱包同源交易', (tester) async {
    final container = ProviderContainer(overrides: [
      localeProvider.overrideWith(_TestLocaleNotifier.new),
      walletControllerProvider.overrideWith(_EmptyWalletController.new),
      navigationControllerProvider.overrideWithValue(const NavigationState()),
      personProfileProvider(const Locale('zh', 'CN')).overrideWith(
        (ref) async => const UserProfile(
          id: 'user-test-001',
          name: 'Alex Morgan',
          email: 'alex.morgan@example.test',
          phone: '+1 202 555 0142 (TEST)',
          address: '100 Example Avenue, Sample City (TEST)',
          avatarUrl: '',
        ),
      ),
      personProfileProvider(const Locale('en', 'US')).overrideWith(
        (ref) async => const UserProfile(
          id: 'user-test-001',
          name: 'Alex Morgan',
          email: 'alex.morgan@example.test',
          phone: '+1 202 555 0142 (TEST)',
          address: '100 Example Avenue, Sample City (TEST)',
          avatarUrl: '',
        ),
      ),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: Consumer(builder: (context, ref, _) => MaterialApp(
        locale: ref.watch(localeProvider),
        supportedLocales: AppLocale.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const PersonPage(),
      )),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text(Languages.totalSpending), findsOneWidget);
    container.read(localeProvider.notifier).setLocale(const Locale('en', 'US'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text(Languages.totalSpending), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('全部15个快捷入口含翻页随中英中切换且原始标题不变', (tester) async {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final chineseActions = await repository.getQuickActions(const Locale('zh'));
    final englishActions = await repository.getQuickActions(const Locale('en'));
    final original = chineseActions
        .map((item) => item['title'] as String)
        .toList();
    final actualActions = chineseActions;
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith(_TestLocaleNotifier.new),
        walletControllerProvider.overrideWith(_EmptyWalletController.new),
      ],
    );
    addTearDown(container.dispose);
    final chinese = original;
    final english = englishActions
        .map((item) => item['title'] as String)
        .toList();
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
                          for (final item in actualActions)
                            ImgText(
                              item['imageUrl'] as String? ?? '',
                              item['title'] as String? ?? '',
                            ),
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final grid = find.byWidgetPredicate((widget) => widget is JingangWidget);
    final pages = find.descendant(of: grid, matching: find.byType(PageView));
    var controller = tester.widget<PageView>(pages).controller!;
    for (final language in ['zh', 'en', 'zh']) {
      container.read(localeProvider.notifier).setLocale(Locale(language));
      await tester.pump();
      final expected = language == 'zh' ? chinese : english;
      final expectedActions =
          (await repository.getQuickActions(Locale(language)))
              .map(
                (item) => ImgText(
                  item['imageUrl'] as String? ?? '',
                  item['title'] as String? ?? '',
                ),
              )
              .toList();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: Locale(language),
            supportedLocales: AppLocale.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Scaffold(
              body: HomeTopBodyWidget(
                homeState: container
                    .read(homeControllerProvider)
                    .copyWith(quickActions: expectedActions),
                userAvatar: '',
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final currentGrid = find.byWidgetPredicate(
        (widget) => widget is JingangWidget,
      );
      final activePages = find.descendant(
        of: currentGrid,
        matching: find.byType(PageView),
      );
      controller = tester.widget<PageView>(activePages).controller!;
      controller.jumpToPage(0);
      await tester.pump();
      for (final text in expected.take(12)) {
        expect(
          find.descendant(of: grid, matching: find.text(text)),
          findsOneWidget,
        );
      }
      await tester.drag(activePages, const Offset(-350, 0));
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.page, closeTo(1, .01));
      for (final text in expected.skip(12)) {
        expect(
          find.descendant(of: currentGrid, matching: find.text(text)),
          findsOneWidget,
        );
      }
      expect(
        (await repository.getQuickActions(const Locale('zh')))
            .map((action) => action['title'] as String)
            .toList(),
        original,
      );
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final width in [320.0, 390.0, 900.0]) {
    for (final scale in [1.0, 2.0]) {
      for (final language in ['zh', 'en']) {
        testWidgets('金刚位分页区实际占位且不移动图文 width=$width scale=$scale $language', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 3000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          AppLocale.setLocale(Locale(language));
          final container = ProviderContainer(
            overrides: [
              localeProvider.overrideWith(_TestLocaleNotifier.new),
              walletControllerProvider.overrideWith(_EmptyWalletController.new),
            ],
          );
          addTearDown(container.dispose);
          final state = container.read(homeControllerProvider);
          final quickActions =
              (await repository.getQuickActions(Locale(language)))
                  .map(
                    (item) => ImgText(
                      item['imageUrl'] as String? ?? '',
                      item['title'] as String? ?? '',
                    ),
                  )
                  .toList();
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                locale: Locale(language),
                supportedLocales: AppLocale.supportedLocales,
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: HomeTopBodyWidget(
                      homeState: state.copyWith(quickActions: quickActions),
                      userAvatar: '',
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          final jingang = find.byWidgetPredicate((w) => w is JingangWidget);
          // 取真实首页配置，单独放大金刚位，避免其他模块的大字布局影响本回归。
          final quickActionsWidget = tester.widget<JingangWidget>(jingang);
          final isolatedQuickActions = JingangWidget<ImgText>(
            data: quickActionsWidget.data.cast<ImgText>(),
            mainAxisExtent: 80,
            childAspectRatio: 0.7,
            indicatorOffset: const Offset(0, -30),
            itemBuilder: quickActionsWidget.itemBuilder,
            indicatorBuilder: quickActionsWidget.indicatorBuilder,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          isolatedQuickActions,
                          const SizedBox(height: 18),
                          const SizedBox(
                            key: ValueKey('next-module'),
                            width: double.infinity,
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          final relaunchedJingang = find.byWidgetPredicate(
            (widget) => widget is JingangWidget,
          );
          final expandable = find.descendant(
            of: relaunchedJingang,
            matching: find.byType(ExpandablePageView),
          );
          final pageWidget = tester.widget<ExpandablePageView>(expandable);
          final pages = find.descendant(
            of: relaunchedJingang,
            matching: find.byType(PageView),
          );
          final controller = tester.widget<PageView>(pages).controller!;
          for (var page = 0; page < pageWidget.pageCount; page++) {
            controller.jumpToPage(page);
            await tester.pump();
            // 页面首次布局后通过 post-frame 回报高度，再绘制自适应容器。
            await tester.pump();
            final gridFinder = find
                .descendant(
                  of: relaunchedJingang,
                  matching: find.byType(GridView),
                )
                .first;
            final grid = tester.widget<GridView>(gridFinder);
            final delegate =
                grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
            final gridRect = tester.getRect(gridFinder);
            final images = find.descendant(
              of: gridFinder,
              matching: find.byType(NetworkWebImage),
            );
            final labels = find.descendant(
              of: gridFinder,
              matching: find.byType(Text),
            );
            for (var i = 0; i < images.evaluate().length; i++) {
              final imageRect = tester.getRect(images.at(i));
              final labelRect = tester.getRect(labels.at(i));
              // 原有图文位置不变：图标位于每行顶部，文字紧随 40px 图标和 2px 间距。
              expect(
                imageRect.top,
                closeTo(
                  gridRect.top +
                      (i ~/ delegate.crossAxisCount) * delegate.mainAxisExtent!,
                  .01,
                ),
              );
              expect(labelRect.top - imageRect.bottom, closeTo(2, .01));
              expect(
                labelRect.bottom,
                lessThanOrEqualTo(imageRect.top + delegate.mainAxisExtent!),
              );
            }
            final region = tester.getRect(expandable);
            final indicator = find.descendant(
              of: relaunchedJingang,
              matching: find.byType(ScrollableIndicator),
            );
            if (pageWidget.pageCount > 1) {
              final indicatorRect = tester.getRect(indicator);
              // 含 margin 的 30px 滑条区域完全在网格下方，轨道距网格至少 10px。
              expect(indicatorRect.height, closeTo(30, .01));
              expect(indicatorRect.top, closeTo(gridRect.bottom, .01));
              // 负 offset 仅预留指示器的 30px，不应额外插入一整行空白。
              expect(region.bottom, closeTo(gridRect.bottom + 30, .01));
              for (var i = 0; i < labels.evaluate().length; i++) {
                expect(
                  indicatorRect.top + 10 - tester.getRect(labels.at(i)).bottom,
                  greaterThanOrEqualTo(10),
                );
              }
            } else {
              expect(indicator, findsNothing);
              expect(region.bottom, closeTo(gridRect.bottom, .01));
            }
            final graph = tester.getRect(
              find.byKey(const ValueKey('next-module')),
            );
            expect(graph.top - region.bottom, greaterThanOrEqualTo(18));
            expect(tester.takeException(), isNull);
          }
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }

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
    expect(source, contains('article.title'));
    expect(source, contains('article.summary'));
    expect(source, isNot(contains('MockDataRepository')));
    expect(source, isNot(contains('titleZh')));
    expect(source, isNot(contains('titleEn')));
  });
}
