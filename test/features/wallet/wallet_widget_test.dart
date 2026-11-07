import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/bean/money_operate_bean.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/data/common_date.dart';
import 'package:sirc/features/wallet/presentation/add_card_page.dart';
import 'package:sirc/features/wallet/presentation/history_details_page.dart';
import 'package:sirc/features/wallet/presentation/history_page.dart';
import 'package:sirc/features/wallet/presentation/wallet_page.dart';

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

  testWidgets('WalletPage renders available balance and action buttons correctly',
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
    final testData = MoneyOperateBean(
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

  testWidgets('AddCardPage renders card preview and form input fields correctly',
      (WidgetTester tester) async {
    setDisplaySize(tester);
    await tester.pumpWidget(_createTestWidget(const AddCardPage()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Add Card'), findsNWidgets(2)); // AppBar title + button text
    expect(find.text('Expire Date:'), findsOneWidget);
    expect(find.text('CVV:'), findsOneWidget);
    expect(find.textContaining('Name On Card'), findsWidgets);
    expect(find.textContaining('Card Number'), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
  });
}

