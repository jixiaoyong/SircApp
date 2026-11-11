import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/data/common_keys.dart';
import 'package:sirc/features/settings/controllers/settings_controller.dart';
import 'package:sirc/features/settings/presentation/initial_page.dart';
import 'package:sirc/features/settings/presentation/language_page.dart';
import 'package:sirc/features/settings/presentation/not_found_page.dart';
import 'package:sirc/features/settings/presentation/notifications_page.dart';
import 'package:sirc/features/wallet/data/wallet_repository.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/routes/app_routes.dart';

final _now = DateTime.now();
final _today = DateTime(_now.year, _now.month, _now.day);
List<Transaction> get _records => [
  Transaction(
    moneyActionName: 'Transfer today',
    time: _today.toIso8601String(),
    moneyAmount: -12,
  ),
  Transaction(
    moneyActionName: 'Recharge today',
    time: _today.toIso8601String(),
    moneyAmount: 24,
  ),
  Transaction(
    moneyActionName: 'Bill today',
    time: _today.toIso8601String(),
    moneyAmount: -8,
  ),
  Transaction(
    moneyActionName: 'Unknown dated',
    time: _today.toIso8601String(),
    moneyAmount: 3,
  ),
  Transaction(
    moneyActionName: 'Unknown undated',
    time: 'Just now',
    moneyAmount: 5,
  ),
];

class _Repository extends WalletRepositoryImpl {
  @override
  Future<List<Transaction>> getTransactions({
    TransactionFilter filter = TransactionFilter.total,
    String? query,
  }) async => _records;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late SharedPreferences prefs;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        walletRepositoryProvider.overrideWithValue(_Repository()),
      ],
    );
  });
  tearDown(() => container.dispose());

  test('语言默认值、双向切换、翻译与持久化', () {
    expect(container.read(localeProvider).languageCode, isIn(['zh', 'en']));
    expect(supportedLanguages, [('中文', 'zh_CN'), ('English', 'en_US')]);
    switchAppLanguage(container, 'en_US');
    expect(container.read(localeProvider), const Locale('en', 'US'));
    expect(prefs.getString(CommonKeys.LOCAL_LANGUAGE), 'en_US');
    expect(Languages.language, 'Language');
    expect(Languages.settings.title, 'Settings');
    switchAppLanguage(container, 'zh_CN');
    expect(container.read(localeProvider), const Locale('zh', 'CN'));
    expect(prefs.getString(CommonKeys.LOCAL_LANGUAGE), 'zh_CN');
    expect(Languages.notifications, '通知');
    expect(Languages.language, '语言');
  });

  test('通知从现有仓库加载，类别不再重复同一数据', () async {
    final sub = container.listen(notificationsControllerProvider, (_, _) {});
    addTearDown(sub.close);
    expect(container.read(notificationsControllerProvider).isLoading, isTrue);
    await Future<void>.delayed(Duration.zero);
    final state = container.read(notificationsControllerProvider);
    expect(state.currentCategoryIndex, 0);
    expect(state.currentExpandIndex, 0);
    expect(state.categories.length, 3);
    expect(state.notificationGroups.length, 4);
    expect(state.notificationGroups.first.$1, Icons.transform);
    expect(state.notificationGroups.map((group) => group.$3.length), [
      1,
      1,
      1,
      1,
    ]);
    expect(state.undatedCount, 1);
    expect(state.visibleItems.single.moneyActionName, 'Transfer today');
    final notifier = container.read(notificationsControllerProvider.notifier);
    notifier.selectNotificationCategory(1);
    expect(
      container
          .read(notificationsControllerProvider)
          .visibleItems
          .single
          .moneyActionName,
      'Recharge today',
    );
    notifier.setCategory(2);
    expect(
      container.read(notificationsControllerProvider).currentCategoryIndex,
      2,
    );
    notifier.selectNotificationCategory(0);
    notifier.setIndexExpand(0);
    expect(
      container.read(notificationsControllerProvider).currentExpandIndex,
      -1,
    );
    notifier.toggleExpand(1);
    expect(
      container.read(notificationsControllerProvider).currentExpandIndex,
      1,
    );
  });

  test('时间边界、未知类别和缺失日期不被伪造', () {
    final records = [
      Transaction(
        moneyActionName: 'Transfer week',
        time: '2026-11-10T10:00:00',
      ),
      Transaction(
        moneyActionName: 'Transfer month',
        time: '2026-11-02T10:00:00',
      ),
      Transaction(
        moneyActionName: 'Transfer year',
        time: '2026-02-02T10:00:00',
      ),
      Transaction(
        moneyActionName: 'Transfer previous year',
        time: '2025-12-02T10:00:00',
      ),
      Transaction(
        moneyActionName: 'Transfer future',
        time: '2027-12-02T10:00:00',
      ),
      Transaction(moneyActionName: 'Transfer undated', time: '刚刚'),
    ];
    final state = NotificationsState(
      transactions: records,
      referenceDate: DateTime(2026, 11, 10, 20),
    );
    expect(state.visibleItems.length, 1);
    expect(state.copyWith(currentCategoryIndex: 1).visibleItems.length, 2);
    expect(state.copyWith(currentCategoryIndex: 2).visibleItems.length, 3);
    expect(state.undatedCount, 1);
  });

  test('引导首次状态、持久化、登录跳转和提示数据', () {
    final notifier = container.read(initialControllerProvider.notifier);
    expect(container.read(initialControllerProvider).isFirstInitial, isTrue);
    notifier.markAsNotFirstInitial();
    expect(container.read(initialControllerProvider).isFirstInitial, isFalse);
    expect(prefs.getBool(CommonKeys.IS_FIRST_INITIAL), isFalse);
    expect(notifier.isUserLoggedIn(), isFalse);
    expect(notifier.getDestinationRoute(), AppRoutes.SIGN_IN);
    prefs.setBool(CommonKeys.IS_LOGIN_SUCCESS, true);
    expect(notifier.isUserLoggedIn(), isTrue);
    expect(notifier.getDestinationRoute(), AppRoutes.MAIN);
    expect(InitialState.initialTips.length, 3);
    expect(InitialState.initialTips.first.$1, isNotEmpty);
    expect(InitialState.initialTips.first.$2, Languages.dontSharePassword);
    expect(InitialState.initialTips.first.$3, isNotEmpty);
  });

  test('引导自动倒计时可取消且不会调用跳转', () {
    final notifier = container.read(initialControllerProvider.notifier);
    var completed = false;
    notifier.startAutoNavigateCountdown(onComplete: () => completed = true);
    expect(container.read(initialControllerProvider).isAutoNavigating, isTrue);
    notifier.cancelCountdown();
    expect(container.read(initialControllerProvider).isAutoNavigating, isFalse);
    expect(completed, isFalse);
  });

  for (final width in [320.0, 390.0, 834.0, 1440.0]) {
    for (final language in ['en', 'zh']) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('通知分段与真实筛选 $width / $language / $scale', (tester) async {
          tester.view.physicalSize = Size(width, 1600);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          container.read(localeProvider.notifier).setLocale(Locale(language));
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: const NotificationsPage(),
              ),
            ),
          );
          await tester.pump();
          expect(find.text('Transfer today'), findsOneWidget);
          expect(find.text('Recharge today'), findsNothing);
          await tester.tap(find.byKey(const ValueKey('period-1')));
          await tester.pump();
          expect(
            container
                .read(notificationsControllerProvider)
                .currentCategoryIndex,
            1,
          );
          await tester.tap(find.byKey(const ValueKey('category-1')));
          await tester.pump();
          expect(find.text('Transfer today'), findsNothing);
          expect(find.text('Recharge today'), findsOneWidget);
          expect(find.byKey(const ValueKey('undated-notice')), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('语言页面真实切换并持久化', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LanguagePage()),
      ),
    );
    expect(find.text('中文'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(prefs.getString(CommonKeys.LOCAL_LANGUAGE), 'en_US');
  });

  testWidgets('404 原有首页入口保留', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: NotFoundPage())),
      ),
    );
    expect(find.text('Not Found'), findsOneWidget);
    expect(find.text('Go to Home'), findsOneWidget);
    expect(find.byIcon(Icons.details), findsOneWidget);
  });

  testWidgets('引导首次页面保留轮播', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: InitialPage()),
      ),
    );
    await tester.pump();
    expect(find.byType(PageView), findsOneWidget);
  });
}
