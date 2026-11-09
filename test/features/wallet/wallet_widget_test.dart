import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  @override
  WalletState build() => const WalletState(
        moneyTypes: ['Send', 'Receive', 'Total'],
        selectedMonth: 'January',
        monthEnglishNameList: ['January'],
      );

  @override
  Future<void> setFilterIndex(int index) async {
    state = state.copyWith(currentFilterIndex: index);
  }
}

Widget _createTestWidget(Widget child) {
  CommonData.realScreenWidth = 390.0;
  return ProviderScope(
    child: ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return MaterialApp(
          home: Scaffold(body: child),
        );
      },
    ),
  );
}

void main() {
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final textScale in [1.0, 3.0]) {
      testWidgets(
          'Wallet actions share available width at $width with text scale $textScale',
          (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_createTestWidget(
          ProviderScope(
            overrides: [
              walletControllerProvider
                  .overrideWith(_LayoutWalletController.new),
            ],
            child: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
              child: const WalletPage(),
            ),
          ),
        ));
        await tester.pump(const Duration(seconds: 2));

        final actions = find.descendant(
          of: find.byType(WalletPage),
          matching: find.byType(InkWell),
        );
        expect(actions, findsNWidgets(3));

        for (var selected = 0; selected < 3; selected++) {
          await tester.ensureVisible(actions.at(selected));
          await tester.tap(actions.at(selected));
          await tester.pump(const Duration(seconds: 2));
          for (var index = 0; index < 3; index++) {
            expect(tester.getSize(actions.at(index)).width,
                closeTo((width - 40 - 20) / 3, 0.01));
            expect(tester.getSize(actions.at(index)).height, 50);
          }
          expect(tester.getTopLeft(actions.first).dx, closeTo(20, 0.01));
          expect(
              tester.getTopRight(actions.last).dx, closeTo(width - 20, 0.01));
          expect(
              tester.getTopLeft(actions.at(1)).dx -
                  tester.getTopRight(actions.first).dx,
              closeTo(10, 0.01));
          final selectedText = tester.widget<Text>(find.descendant(
            of: actions.at(selected),
            matching: find.byType(Text),
          ));
          expect(selectedText.data,
              [Languages.send, Languages.receive, Languages.total][selected]);
          expect(selectedText.maxLines, 1);
          expect(selectedText.overflow, TextOverflow.ellipsis);
          expect(tester.takeException(), isNull);
        }
      });
    }
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
  });

  testWidgets('HistoryPage renders title, balance and month selector correctly',
      (WidgetTester tester) async {
    setDisplaySize(tester);
    await tester.pumpWidget(_createTestWidget(const HistoryPage()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('History'), findsOneWidget);
    expect(find.text('January'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('HistoryDetailsPage renders transaction info and emotion',
      (WidgetTester tester) async {
    setDisplaySize(tester);
    final testData = Transaction(
      userIcon: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
      moneyActionName: 'Salary Bonus',
      moneyAmount: 250.75,
      time: 'Just now',
    );

    await tester.pumpWidget(
      _createTestWidget(
        HistoryDetailsPage(
          data: testData,
          heroTag: 'hero_test_tag',
        ),
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
        find.text('Add Card'), findsNWidgets(2)); // AppBar title + button text
    expect(find.text('Expire Date:'), findsOneWidget);
    expect(find.text('CVV:'), findsOneWidget);
    expect(find.textContaining('Name On Card'), findsWidgets);
    expect(find.textContaining('Card Number'), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
  });
}
