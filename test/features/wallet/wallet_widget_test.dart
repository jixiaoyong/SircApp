import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/features/wallet/domain/models/transaction.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/data/common_data.dart';
import 'package:sirc/features/wallet/presentation/add_card_page.dart';
import 'package:sirc/features/wallet/presentation/history_details_page.dart';
import 'package:sirc/features/wallet/presentation/history_page.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';

// Keep the action layout tests independent of transaction loading and row layout.
class _LayoutWalletController extends WalletController {
  int filterCalls = 0;

  @override
  WalletState build() => const WalletState(
    moneyTypes: ['Send', 'Receive', 'Total'],
    selectedMonth: 'January',
    monthEnglishNameList: ['January'],
  );

  @override
  Future<void> setFilterIndex(int index) async {
    filterCalls++;
    state = state.copyWith(currentFilterIndex: index);
  }
}

class _TestLocaleNotifier extends LocaleNotifier {
  _TestLocaleNotifier(this.locale);
  final Locale locale;

  @override
  Locale build() {
    AppLocale.setLocale(locale);
    return locale;
  }
}

Widget _createTestWidget(Widget child) {
  CommonData.realScreenWidth = 390.0;
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  for (final width in [320.0, 375.0, 430.0, 834.0, 1461.0]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets(
        'Wallet selected action fills remaining width at $width, scale $textScale',
        (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _createTestWidget(
              ProviderScope(
                overrides: [
                  walletControllerProvider.overrideWith(
                    _LayoutWalletController.new,
                  ),
                ],
                child: MediaQuery(
                  data: MediaQueryData(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: const WalletPage(),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 1100));

          final actions = find.descendant(
            of: find.byType(WalletPage),
            matching: find.byType(InkWell),
          );
          expect(actions, findsNWidgets(3));

          for (var selected = 0; selected < 3; selected++) {
            await tester.ensureVisible(actions.at(selected));
            await tester.tap(actions.at(selected));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 1100));
            for (var index = 0; index < 3; index++) {
              expect(
                tester.getSize(actions.at(index)).width,
                closeTo(index == selected ? width - 160 : 50, 0.01),
              );
              expect(tester.getSize(actions.at(index)).height, 50);
            }
            expect(tester.getTopLeft(actions.first).dx, closeTo(20, 0.01));
            expect(
              tester.getTopRight(actions.last).dx,
              closeTo(width - 20, 0.01),
            );
            for (var index = 1; index < 3; index++) {
              expect(
                tester.getTopLeft(actions.at(index)).dx -
                    tester.getTopRight(actions.at(index - 1)).dx,
                closeTo(10, 0.01),
              );
            }
            final selectedText = tester.widget<Text>(
              find.descendant(
                of: actions.at(selected),
                matching: find.byType(Text),
              ),
            );
            expect(
              selectedText.data,
              [Languages.send, Languages.receive, Languages.total][selected],
            );
            expect(selectedText.maxLines, 1);
            expect(selectedText.overflow, TextOverflow.ellipsis);
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }

  testWidgets('钱包宽度动画双向连续、途中反向且每次点击仅筛选一次', (tester) async {
    tester.view.physicalSize = const Size(1461, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = _LayoutWalletController();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [walletControllerProvider.overrideWith(() => controller)],
        child: const MaterialApp(
          home: Scaffold(body: SizedBox(width: 320, child: WalletPage())),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1100));
    final actions = find.descendant(
      of: find.byType(WalletPage),
      matching: find.byType(InkWell),
    );
    double width(int index) => tester.getSize(actions.at(index)).width;
    const expanded = 320.0 - 160;
    void expectConstantRow() {
      expect(width(0) + width(1) + width(2), closeTo(260, .01));
      for (var i = 1; i < 3; i++) {
        expect(
          tester.getTopLeft(actions.at(i)).dx -
              tester.getTopRight(actions.at(i - 1)).dx,
          closeTo(10, .01),
        );
      }
    }

    expectConstantRow();
    expect(width(0), closeTo(expanded, .01));
    await tester.tap(actions.at(1));
    await tester.pump();
    expect(width(0), closeTo(expanded, .01));
    expect(width(1), 50);
    await tester.pump(const Duration(milliseconds: 400));
    expectConstantRow();
    final shrinking = width(0);
    final growing = width(1);
    expect(expanded - shrinking, closeTo(growing - 50, .01));
    expect(shrinking, inExclusiveRange(50, expanded));
    expect(growing, inExclusiveRange(50, expanded));
    await tester.tap(actions.at(0));
    await tester.pump();
    expect(width(0), closeTo(shrinking, .01));
    expect(width(1), closeTo(growing, .01));
    await tester.pump(const Duration(milliseconds: 200));
    expectConstantRow();
    expect(width(0), greaterThan(shrinking));
    expect(width(1), lessThan(growing));
    for (final index in [2, 1, 2, 0, 0]) {
      final before = List.generate(3, width);
      await tester.tap(actions.at(index));
      await tester.pump();
      for (var i = 0; i < 3; i++) {
        expect(width(i), closeTo(before[i], .01));
      }
      await tester.pump(const Duration(milliseconds: 80));
      expectConstantRow();
      expect(tester.takeException(), isNull);
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1100));
    expect(controller.filterCalls, 7);
    expect(
      ProviderScope.containerOf(tester.element(find.byType(WalletPage)))
          .read(walletControllerProvider)
          .currentFilterIndex,
      0,
    );
    expect(width(0), closeTo(expanded, .01));
    expect(width(1), 50);
    expect(width(2), 50);
    expect(tester.takeException(), isNull);
  });

  for (final parentWidth in [40.0, 80.0, 160.0, 209.0]) {
    testWidgets('极窄父容器 $parentWidth 安全降级不溢出', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletControllerProvider.overrideWith(_LayoutWalletController.new),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(width: parentWidth, child: const WalletPage()),
            ),
          ),
        ),
      );
      await tester.pump();
      final actions = find.descendant(
        of: find.byType(WalletPage),
        matching: find.byType(InkWell),
      );
      final total = actions.evaluate().fold<double>(
        0,
        (sum, element) =>
            sum + tester.getSize(find.byWidget(element.widget)).width,
      );
      expect(
        total,
        lessThanOrEqualTo((parentWidth - 40).clamp(0, double.infinity) + .01),
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in [const Locale('en', 'US'), const Locale('zh', 'CN')]) {
    testWidgets('窄分栏与双倍字体语义完整 $locale', (tester) async {
      AppLocale.setLocale(locale);
      addTearDown(() => AppLocale.setLocale(const Locale('en', 'US')));
      tester.view.physicalSize = const Size(1461, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletControllerProvider.overrideWith(_LayoutWalletController.new),
            localeProvider.overrideWith(() => _TestLocaleNotifier(locale)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(2)),
                child: SizedBox(width: 320, child: WalletPage()),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));
      final actions = find.descendant(
        of: find.byType(WalletPage),
        matching: find.byType(InkWell),
      );
      for (var index = 0; index < 3; index++) {
        await tester.tap(actions.at(index));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(tester.takeException(), isNull);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1100));
        expect(Languages.send, locale.languageCode == 'zh' ? '发送' : 'Send');
        expect(
          find.ancestor(
            of: actions.at(index),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.properties.label ==
                      [
                        Languages.send,
                        Languages.receive,
                        Languages.total,
                      ][index],
            ),
          ),
          findsOneWidget,
        );
      }
    });
  }

  setUpAll(() {
    AppLocale.setLocale(const Locale('en', 'US'));
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  void setDisplaySize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets(
    'WalletPage renders available balance and action buttons correctly',
    (WidgetTester tester) async {
      setDisplaySize(tester);
      await tester.pumpWidget(_createTestWidget(const WalletPage()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets(
    'HistoryPage renders title, balance and month selector correctly',
    (WidgetTester tester) async {
      setDisplaySize(tester);
      await tester.pumpWidget(_createTestWidget(const HistoryPage()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('History'), findsOneWidget);
      expect(find.text('January'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    },
  );

  testWidgets('HistoryDetailsPage renders transaction info and emotion', (
    WidgetTester tester,
  ) async {
    setDisplaySize(tester);
    final testData = Transaction(
      userIcon: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
      moneyActionName: 'Salary Bonus',
      moneyAmount: 250.75,
      time: 'Just now',
    );

    await tester.pumpWidget(
      _createTestWidget(
        HistoryDetailsPage(data: testData, heroTag: 'hero_test_tag'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Salary Bonus'), findsOneWidget);
    expect(find.text('🤑'), findsOneWidget);
  });

  testWidgets(
    'AddCardPage renders card preview and form input fields correctly',
    (WidgetTester tester) async {
      setDisplaySize(tester);
      await tester.pumpWidget(_createTestWidget(const AddCardPage()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Add Card'),
        findsNWidgets(2),
      ); // AppBar title + button text
      expect(find.text('Expire Date:'), findsOneWidget);
      expect(find.text('CVV:'), findsOneWidget);
      expect(find.textContaining('Name On Card'), findsWidgets);
      expect(find.textContaining('Card Number'), findsWidgets);

      await tester.pump(const Duration(seconds: 2));
    },
  );
}
