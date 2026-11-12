import 'package:flutter/material.dart';
import 'package:sirc/mock/mock_data_repository.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/home/data/article_repository.dart';
import 'package:sirc/features/home/presentation/article_detail_page.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/features/home/presentation/person_page.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/features/wallet/data/wallet_repository.dart';
import 'package:sirc/features/wallet/presentation/add_card_page.dart';
import 'package:sirc/features/wallet/presentation/card_management_page.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/presentation/transaction_detail_page.dart';
import 'package:sirc/features/wallet/presentation/history_page.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';
import 'package:sirc/routes/app_router.dart';
import 'package:sirc/routes/source_detail_navigation.dart';

void main() {
  late MockDataRepository mock;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mock = MockDataRepository();
    await mock.wallet;
    await mock.articles;
    await mock.user;
  });
  test('交易业务入口兼容裸交易、Map及非法Hero标识', () {
    final transaction = Transaction(
      moneyActionName: 'Actual record',
      moneyAmount: -12,
    );
    expect(
      TransactionDetailPage.fromExtra(extra: transaction).data,
      same(transaction),
    );
    final mapped = TransactionDetailPage.fromExtra(
      extra: {'data': transaction, 'heroTag': 'source-hero'},
    );
    expect(mapped.data, same(transaction));
    expect(mapped.heroTag, 'source-hero');
    final invalidTag = TransactionDetailPage.fromExtra(
      extra: {'data': transaction, 'heroTag': 123},
    );
    expect(invalidTag.data, same(transaction));
    expect(invalidTag.heroTag, 'default');
  });
  Future<void> frames(WidgetTester tester) async {
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  for (final width in [390.0, 1200.0]) {
    for (final initial in [
      '/person',
      '/person/card',
      '/person/add-card',
      '/person/edit-card/card-test-001',
      '/wallet/cards',
    ]) {
      testWidgets('统一卡片管理 $initial 在 $width 保留来源与管理交互', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1100);
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({
          CommonKeys.IS_LOGIN_SUCCESS: true,
          CommonKeys.LOCAL_LANGUAGE: 'en_US',
        });
        final prefs = await SharedPreferences.getInstance();
        final repository = WalletRepositoryImpl(null, mock, const Locale('en'));
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            mockDataRepositoryProvider.overrideWithValue(mock),
            walletRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);
        final router = createAppRouter(
          container.read(storageServiceProvider),
          initialLocation: initial,
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              theme: AppTheme.lightTheme,
            ),
          ),
        );
        await frames(tester);
        final source = initial.startsWith('/person') ? '/person' : '/wallet';
        final management = source == '/person'
            ? '/person/card'
            : '/wallet/cards';
        if (initial == '/person') {
          final cards = find.descendant(
            of: find.byType(PersonPage),
            matching: find.byIcon(Icons.credit_card_outlined),
          );
          await tester.ensureVisible(cards);
          await tester.tap(cards);
          await frames(tester);
        } else if (initial.contains('add-card') ||
            initial.contains('edit-card')) {
          expect(find.byType(CardEditorPage), findsOneWidget);
          await tester.tap(
            find.descendant(
              of: find.byType(CardEditorPage),
              matching: find.byType(BackButton),
            ),
          );
          await frames(tester);
        }
        expect(router.routeInformationProvider.value.uri.path, management);
        expect(find.byType(CardManagementPage), findsOneWidget);
        expect(find.text('Manage cards'), findsOneWidget);
        expect(find.text('8932 6283 3243 3232'), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('managed-card-card-test-001')),
            matching: find.textContaining('•••• 0042'),
          ),
          findsOneWidget,
        );
        for (final edit in [false, true]) {
          await tester.tap(
            edit
                ? find.byKey(const ValueKey('edit-card-card-test-001'))
                : find.descendant(
                    of: find.byType(CardManagementPage),
                    matching: find.text(Languages.addCard),
                  ),
          );
          await frames(tester);
          expect(
            router.routeInformationProvider.value.uri.path,
            edit ? '$source/edit-card/card-test-001' : '$source/add-card',
          );
          expect(find.byType(CardEditorPage), findsOneWidget);
          expect(
            tester
                .widget<CardEditorPage>(find.byType(CardEditorPage))
                .editingId,
            edit ? 'card-test-001' : null,
          );
          // 系统返回和页面返回均应回到相同来源的管理页。
          if (edit) {
            await tester.binding.handlePopRoute();
          } else {
            await tester.tap(
              find.descendant(
                of: find.byType(CardEditorPage),
                matching: find.byType(BackButton),
              ),
            );
          }
          await frames(tester);
          expect(router.routeInformationProvider.value.uri.path, management);
        }
        final wallet = container.read(walletControllerProvider.notifier);
        for (final card in [
          ...container.read(walletControllerProvider).cards,
        ]) {
          await wallet.deleteCard(card.id);
        }
        await frames(tester);
        expect(
          find.descendant(
            of: find.byType(CardManagementPage),
            matching: find.text(Languages.wallet.noCardsYet),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('edit-card-card-test-001')),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(CardManagementPage),
            matching: find.text(Languages.addCard),
          ),
          findsNWidgets(2),
        );
        await tester.tap(
          find.descendant(
            of: find.byType(CardManagementPage),
            matching: find.byType(BackButton),
          ),
        );
        await frames(tester);
        expect(router.routeInformationProvider.value.uri.path, source);
        expect(router.canPop(), isFalse);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final source in [
    ('/main', HomePage),
    ('/wallet', WalletPage),
    ('/history', HistoryPage),
    ('/person', PersonPage),
  ]) {
    testWidgets('${source.$1} 主从同级替换跨断点与返回保留来源', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 1100);
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        CommonKeys.IS_LOGIN_SUCCESS: true,
        CommonKeys.LOCAL_LANGUAGE: 'en_US',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          mockDataRepositoryProvider.overrideWithValue(mock),
        ],
      );
      addTearDown(container.dispose);
      final router = createAppRouter(
        container.read(storageServiceProvider),
        initialLocation: source.$1,
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        ),
      );
      await frames(tester);
      final semantics = tester.ensureSemantics();
      final list = tester.element(find.byType(source.$2));
      for (var index = 0; index < 3; index++) {
        openSourceDetail(
          list,
          'transaction',
          extra: {
            'data': Transaction(
              moneyActionName: 'record-$index',
              moneyAmount: -10.0 - index,
            ),
            'heroTag': 'test-$index',
          },
        );
        await frames(tester);
        expect(find.byType(source.$2), findsOneWidget);
        expect(tester.element(find.byType(source.$2)), same(list));
        // Flutter Web 使用语义 DOM；只检查 widget 存在会漏掉嵌套
        // Navigator 的 ModalBarrier 吞掉左窗格及 Rail 的真实浏览器问题。
        expect(find.bySemanticsLabel(RegExp('Wallet')).evaluate(), isNotEmpty);
        expect(tester.getSemantics(find.byType(NavigationRail)), isNotNull);
        expect(
          tester
              .getSemantics(find.byType(source.$2))
              .debugListChildrenInOrder(DebugSemanticsDumpOrder.traversalOrder),
          isNotEmpty,
        );
        expect(
          tester
              .widget<TransactionDetailPage>(find.byType(TransactionDetailPage))
              .data!
              .moneyActionName,
          'record-$index',
        );
        expect(
          router.routeInformationProvider.value.uri.path,
          '${source.$1}/transaction',
        );
      }
      final detail = tester.element(find.byType(TransactionDetailPage));
      for (final width in [839.0, 840.0, 390.0, 1200.0]) {
        tester.view.physicalSize = Size(width, 1100);
        await frames(tester);
        expect(
          tester.element(find.byType(TransactionDetailPage)),
          same(detail),
        );
        expect(
          find.byType(source.$2),
          width >= 840 ? findsOneWidget : findsNothing,
        );
        expect(
          tester.element(find.byType(source.$2, skipOffstage: false)),
          same(list),
        );
        expect(tester.takeException(), isNull);
      }
      await tester.tap(
        find.descendant(
          of: find.byType(TransactionDetailPage),
          matching: find.byIcon(Icons.arrow_back),
        ),
      );
      await frames(tester);
      expect(router.routeInformationProvider.value.uri.path, source.$1);
      expect(router.canPop(), isFalse);
      semantics.dispose();
      expect(tester.element(find.byType(source.$2)), same(list));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('文章详情区分loading、error、not-found与success并支持重试', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({CommonKeys.IS_LOGIN_SUCCESS: true});
    final prefs = await SharedPreferences.getInstance();
    var attempts = 0;
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        articleDetailProvider.overrideWith((ref, key) async {
          attempts++;
          if (key.id == 'missing') return null;
          if (attempts == 1) throw StateError('temporary failure');
          return const Article(
            id: '0-0',
            title: 'Localized title',
            summary: 'Localized summary',
            body: 'Localized body',
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ArticleDetailPage(id: '0-0'),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text(Languages.common.loadFailed), findsOneWidget);
    await tester.tap(find.text(Languages.common.retry));
    await tester.pumpAndSettle();
    expect(find.text('Localized title'), findsNWidgets(2));
    expect(find.text('Localized body'), findsOneWidget);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ArticleDetailPage(id: 'missing'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(Languages.home.articleNotFound), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('文章静态示例跨断点与返回', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1100);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({CommonKeys.IS_LOGIN_SUCCESS: true});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        mockDataRepositoryProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);
    final router = createAppRouter(
      container.read(storageServiceProvider),
      initialLocation: '/main',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      ),
    );
    await frames(tester);
    final article = find.byKey(const ValueKey('home-article-0-0'));
    await tester.ensureVisible(article);
    await tester.tap(article);
    await frames(tester);
    expect(find.byType(ArticleDetailPage), findsOneWidget);
    expect(find.textContaining('Static example'), findsOneWidget);
    final detail = tester.element(find.byType(ArticleDetailPage));
    tester.view.physicalSize = const Size(390, 1100);
    await frames(tester);
    expect(tester.element(find.byType(ArticleDetailPage)), same(detail));
    expect(find.byType(HomePage), findsNothing);
    router.pop();
    await frames(tester);
    expect(router.routeInformationProvider.value.uri.path, '/main');
    expect(tester.takeException(), isNull);
  });
}
