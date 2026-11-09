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
import 'package:sirc/routes/app_routes.dart';

class _LongCategoryState extends NotificationsState {
  static const options = [
    'All notifications received during this exceptionally long reporting week 通知分类完整文本',
    'All notifications received during this exceptionally long reporting month 通知分类完整文本',
  ];

  const _LongCategoryState({super.currentCategoryIndex});

  @override
  List<String> get categories => options;

  @override
  NotificationsState copyWith({
    int? currentCategoryIndex,
    int? currentExpandIndex,
  }) => _LongCategoryState(
    currentCategoryIndex: currentCategoryIndex ?? this.currentCategoryIndex,
  );
}

class _LongCategoryController extends NotificationsController {
  @override
  NotificationsState build() => const _LongCategoryState();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Settings - 多语言切换与 LocaleProvider 测试', () {
    test('初始语言状态与本地存储校验', () {
      final locale = container.read(localeProvider);
      // 默认系统环境语言（测试环境为 en）
      expect(locale.languageCode, isIn(['zh', 'en']));
      expect(Languages.language, isIn(['语言', 'Language']));
    });

    test('切换语言至英文 (en_US) 并持久化保存', () {
      final notifier = container.read(localeProvider.notifier);
      notifier.setLocale(const Locale('en', 'US'));

      final currentLocale = container.read(localeProvider);
      expect(currentLocale.languageCode, equals('en'));
      expect(currentLocale.countryCode, equals('US'));
      expect(prefs.getString(CommonKeys.LOCAL_LANGUAGE), equals('en_US'));

      // 验证翻译扩展即时更新为英文
      expect(Languages.language, equals('Language'));
      expect(Languages.settings.title, equals('Settings'));
    });

    test('通过 switchAppLanguage 辅助函数切换至中文', () {
      switchAppLanguage(container, 'zh_CN');

      final locale = container.read(localeProvider);
      expect(locale.languageCode, equals('zh'));
      expect(locale.countryCode, equals('CN'));
      expect(prefs.getString(CommonKeys.LOCAL_LANGUAGE), equals('zh_CN'));
      expect(Languages.notifications, equals('通知'));
      expect(Languages.language, equals('语言'));
    });

    test('supportedLanguages 包含中英语言并采用 Dart 3 原生 Records', () {
      expect(supportedLanguages.length, equals(2));

      final (zhName, zhCode) = supportedLanguages[0];
      expect(zhName, equals('中文'));
      expect(zhCode, equals('zh_CN'));

      final (enName, enCode) = supportedLanguages[1];
      expect(enName, equals('English'));
      expect(enCode, equals('en_US'));
    });
  });

  group('Settings - 通知中心控制器 NotificationsNotifier 测试', () {
    test('初始通知状态与分组数据', () {
      final state = container.read(notificationsControllerProvider);
      expect(state.currentCategoryIndex, equals(0));
      expect(state.currentExpandIndex, equals(0));
      expect(state.categories.length, equals(3));
      expect(state.notificationGroups.length, equals(4));

      // 验证分组元组解构
      final (icon, title, items) = state.notificationGroups.first;
      expect(icon, equals(Icons.transform));
      expect(title, isNotEmpty);
      expect(items, isNotEmpty);
    });

    test('切换分类索引', () {
      final notifier = container.read(notificationsControllerProvider.notifier);
      notifier.setCategory(2);

      final state = container.read(notificationsControllerProvider);
      expect(state.currentCategoryIndex, equals(2));
    });

    test('展开与折叠卡片交互 (切换当前已展开项与展开新项)', () {
      final notifier = container.read(notificationsControllerProvider.notifier);

      // 当前是 0，再次点击 0 应收起变为 -1
      notifier.setIndexExpand(0);
      expect(
        container.read(notificationsControllerProvider).currentExpandIndex,
        equals(-1),
      );

      // 点击索引 1 展开
      notifier.toggleExpand(1);
      expect(
        container.read(notificationsControllerProvider).currentExpandIndex,
        equals(1),
      );
    });
  });

  group('Settings - 启动引导与闪屏控制器 InitialController 测试', () {
    test('首次启动默认为 true，调用 markAsNotFirstInitial 后更新并持久化', () {
      final notifier = container.read(initialControllerProvider.notifier);
      final initialState = container.read(initialControllerProvider);

      expect(initialState.isFirstInitial, isTrue);

      notifier.markAsNotFirstInitial();
      final updatedState = container.read(initialControllerProvider);

      expect(updatedState.isFirstInitial, isFalse);
      expect(prefs.getBool(CommonKeys.IS_FIRST_INITIAL), isFalse);
    });

    test('根据用户登录状态正确计算下一跳转路由', () {
      final notifier = container.read(initialControllerProvider.notifier);

      // 未登录
      expect(notifier.isUserLoggedIn(), isFalse);
      expect(notifier.getDestinationRoute(), equals(AppRoutes.SIGN_IN));

      // 模拟已登录
      prefs.setBool(CommonKeys.IS_LOGIN_SUCCESS, true);
      expect(notifier.isUserLoggedIn(), isTrue);
      expect(notifier.getDestinationRoute(), equals(AppRoutes.MAIN));
    });

    test('倒计时自动跳转与取消倒计时', () {
      final notifier = container.read(initialControllerProvider.notifier);

      bool hasCompleted = false;
      notifier.startAutoNavigateCountdown(
        onComplete: () {
          hasCompleted = true;
        },
      );

      expect(
        container.read(initialControllerProvider).isAutoNavigating,
        isTrue,
      );

      // 取消倒计时
      notifier.cancelCountdown();
      expect(
        container.read(initialControllerProvider).isAutoNavigating,
        isFalse,
      );
      expect(hasCompleted, isFalse);
    });

    test('引导提示数据 initialTips 元组与文案校验', () {
      final tips = InitialState.initialTips;
      expect(tips.length, equals(3));

      final (img1, title1, sub1) = tips[0];
      expect(img1, isNotEmpty);
      expect(title1, equals(Languages.dontSharePassword));
      expect(sub1, isNotEmpty);
    });
  });

  group('NotificationsPage 响应式布局回归', () {
    for (final width in [320.0, 390.0, 834.0, 1440.0]) {
      for (final language in ['en', 'zh']) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('$width / $language / ${scale}x 分类选择与展开收起', (
            tester,
          ) async {
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
            expect(tester.takeException(), isNull);

            final titleRect = tester.getRect(find.text(Languages.category));
            final dropdownRect = tester.getRect(
              find.byType(DropdownButton<int>),
            );
            if ((scale == 1 && width >= 390) || width >= 834) {
              expect(titleRect.center.dy, closeTo(dropdownRect.center.dy, 1));
            }
            if (language == 'en' && scale == 2 && width <= 390) {
              expect(dropdownRect.top, greaterThan(titleRect.bottom));
            }

            await tester.tap(find.byType(DropdownButton<int>));
            // Network image loading indicators animate indefinitely in widget tests.
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 400));
            expect(tester.takeException(), isNull);
            await tester.tap(find.text(Languages.thisMonth).last);
            // Network image loading indicators animate indefinitely in widget tests.
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 400));
            expect(
              container
                  .read(notificationsControllerProvider)
                  .currentCategoryIndex,
              1,
            );
            expect(
              tester
                  .widget<DropdownButton<int>>(find.byType(DropdownButton<int>))
                  .value,
              1,
            );
            expect(tester.takeException(), isNull);

            await tester.tap(find.byIcon(Icons.keyboard_arrow_up_outlined));
            await tester.pump();
            expect(
              container
                  .read(notificationsControllerProvider)
                  .currentExpandIndex,
              -1,
            );
            expect(find.byIcon(Icons.keyboard_arrow_up_outlined), findsNothing);
            await tester.tap(find.text(Languages.transfers));
            await tester.pump();
            expect(
              container
                  .read(notificationsControllerProvider)
                  .currentExpandIndex,
              0,
            );
            expect(
              find.byIcon(Icons.keyboard_arrow_up_outlined),
              findsOneWidget,
            );
            expect(tester.takeException(), isNull);
          });
        }
      }
    }

    testWidgets('长分类选项保留完整文本语义且菜单可选择', (tester) async {
      tester.view.physicalSize = const Size(320, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final longContainer = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationsControllerProvider.overrideWith(
            _LongCategoryController.new,
          ),
        ],
      );
      addTearDown(longContainer.dispose);
      longContainer.read(localeProvider.notifier).setLocale(const Locale('en'));
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: longContainer,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: const NotificationsPage(),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        find.bySemanticsLabel(_LongCategoryState.options.first),
        findsOneWidget,
      );
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(
        find.text(_LongCategoryState.options.last).last,
      );
      await tester.tap(find.text(_LongCategoryState.options.last).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        longContainer
            .read(notificationsControllerProvider)
            .currentCategoryIndex,
        1,
      );
      expect(
        find.bySemanticsLabel(_LongCategoryState.options.last),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  });

  group('Presentation UI 页面集成与渲染测试', () {
    testWidgets('NotFoundPage 正常渲染图标与按钮', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: Scaffold(body: NotFoundPage())),
        ),
      );
      await tester.pump();

      expect(find.text('Not Found'), findsOneWidget);
      expect(find.text('Go to Home'), findsOneWidget);
      expect(find.byIcon(Icons.details), findsOneWidget);
    });

    testWidgets('LanguagePage 正常渲染语言列表与切换', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: LanguagePage()),
        ),
      );
      await tester.pump();

      expect(find.text('中文'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // 点击切换为 English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(prefs.getString(CommonKeys.LOCAL_LANGUAGE), equals('en_US'));
    });

    testWidgets('NotificationsPage 正常渲染分类与卡片展开折叠交互', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: NotificationsPage()),
        ),
      );
      await tester.pump();

      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.byType(DropdownButton<int>), findsOneWidget);

      // 验证第一组卡片有展开箭头
      expect(find.byIcon(Icons.keyboard_arrow_up_outlined), findsOneWidget);

      // 点击第一项的 ListTile 折叠
      await tester.tap(find.byIcon(Icons.keyboard_arrow_up_outlined));
      await tester.pump();

      // 折叠后应显示向下箭头
      expect(find.byIcon(Icons.keyboard_arrow_down_outlined), findsWidgets);
    });

    testWidgets('InitialPage 首次启动时展示引导轮播 PageView 与 Get Start', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: InitialPage()),
        ),
      );
      await tester.pump();

      expect(find.byType(InitialPage), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });
  });
}
