import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/presentation/card_brand_label.dart';

void main() {
  late Locale originalLocale;
  setUp(() {
    originalLocale = AppLocale.currentLocale;
    AppLocale.setLocale(const Locale('en', 'US'));
  });
  tearDown(() => AppLocale.setLocale(originalLocale));

  testWidgets('已知品牌中英中切换且原始数据和未知品牌不变', (tester) async {
    final originalTypes = ['Visa', 'MasterCard', 'UnionPay', null];
    for (final language in ['zh', 'en', 'zh']) {
      AppLocale.setLocale(Locale(language));
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: Column(
              children: [
                for (final type in originalTypes)
                  BankCardWidget(
                    bankName: 'My Visa Bank',
                    cardNumber: '12345678',
                    ownerName: 'OWNER',
                    expirationDate: '08/29',
                    cardType: type,
                    width: 380,
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text(language == 'zh' ? '维萨卡' : 'Visa'), findsNWidgets(2));
      expect(
        find.text(language == 'zh' ? '万事达卡' : 'MasterCard'),
        findsOneWidget,
      );
      expect(find.text('UnionPay'), findsOneWidget);
      expect(find.text('My Visa Bank'), findsNWidgets(4));
      expect(
        tester
            .widgetList<BankCardWidget>(find.byType(BankCardWidget))
            .map((card) => card.cardType)
            .toList(),
        originalTypes,
      );
      expect(cardBrandLabel('  Custom Brand  '), '  Custom Brand  ');
      expect(cardBrandLabel('mastercard'), Languages.wallet.masterCard);
      expect(tester.takeException(), isNull);
    }
  });
  for (final background in [
    Colors.white,
    const Color(0xFFF1F2F3),
    Colors.black,
  ]) {
    testWidgets(
      'C iridescent edge and opaque surface stay readable on $background',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: background,
              body: Center(
                child: BankCardWidget(
                  bankName: 'Sirc Bank',
                  cardNumber: '**** **** **** 3232',
                  ownerName: 'ALEX CHEN',
                  expirationDate: '08/29',
                  cardType: 'MasterCard',
                  width: 380,
                ),
              ),
            ),
          ),
        );
        final edge = find.byKey(const ValueKey('bank-card-iridescent-edge'));
        final surface = find.byKey(const ValueKey('bank-card-dark-surface'));
        expect(find.descendant(of: edge, matching: surface), findsOneWidget);
        expect(find.byType(BackdropFilter), findsNothing);
        final edgeDecoration =
            tester.widget<DecoratedBox>(edge).decoration as BoxDecoration;
        final edgeGradient = edgeDecoration.gradient! as LinearGradient;
        expect(edgeGradient.colors, const [
          Color(0xFF91AAB0),
          Color(0xFFA99AA9),
          Color(0xFF697F89),
          Color(0xFFB4B39B),
        ]);
        expect(edgeGradient.stops, [0, .32, .65, 1]);
        expect(edgeDecoration.borderRadius, BorderRadius.circular(20));
        expect(edgeDecoration.boxShadow!.single.color, const Color(0x12000000));
        final decoration =
            tester.widget<Container>(surface).decoration! as BoxDecoration;
        final gradient = decoration.gradient! as LinearGradient;
        expect(gradient.colors, const [
          Color(0xFF2E363B),
          Color(0xFF252B30),
          Color(0xFF2B3034),
        ]);
        expect(gradient.stops, [0, .6, 1]);
        expect(decoration.borderRadius, BorderRadius.circular(18));
        final edgeRect = tester.getRect(edge);
        final surfaceRect = tester.getRect(surface);
        expect(edgeRect.size, const Size(380, 200));
        expect(surfaceRect, edgeRect.deflate(2));
        expect(find.byType(Image), findsOneWidget);
        for (final text in [
          'Sirc Bank',
          '**** **** **** 3232 ',
          'ALEX CHEN',
          '08/29',
          'MasterCard',
        ]) {
          expect(find.text(text), findsOneWidget);
          final style = tester.widget<Text>(find.text(text)).style!;
          expect(style.color!.r, 1);
          expect(style.color!.g, 1);
          expect(style.color!.b, 1);
          expect(style.color!.a, greaterThanOrEqualTo(.7));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('选中只提亮微虹边缘，扫光绘制在文字下且默认不启用', (tester) async {
    Future<void> render({bool selected = false, double? progress}) =>
        tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: BankCardWidget(
                bankName: 'Bank',
                cardNumber: '12345678',
                ownerName: 'OWNER',
                expirationDate: '08/29',
                cardType: 'UnionPay',
                width: 380,
                isSelected: selected,
                selectionHighlightProgress: progress,
              ),
            ),
          ),
        );
    await render();
    final original =
        tester
                .widget<DecoratedBox>(
                  find.byKey(const ValueKey('bank-card-iridescent-edge')),
                )
                .decoration
            as BoxDecoration;
    expect(
      tester
          .widget<BankCardWidget>(find.byType(BankCardWidget))
          .selectionHighlightProgress,
      isNull,
    );
    await render(selected: true, progress: .5);
    final selected =
        tester
                .widget<DecoratedBox>(
                  find.byKey(const ValueKey('bank-card-iridescent-edge')),
                )
                .decoration
            as BoxDecoration;
    final originalColors = (original.gradient! as LinearGradient).colors;
    final selectedColors = (selected.gradient! as LinearGradient).colors;
    for (var i = 0; i < originalColors.length; i++) {
      expect(
        selectedColors[i].computeLuminance(),
        greaterThan(originalColors[i].computeLuminance()),
      );
    }
    final paint = tester.widget<CustomPaint>(
      find
          .descendant(
            of: find.byKey(const ValueKey('bank-card-dark-surface')),
            matching: find.byType(CustomPaint),
          )
          .first,
    );
    expect(paint.painter, isNotNull);
    expect(paint.foregroundPainter, isNull);
    expect(
      find.descendant(
        of: find.byType(CustomPaint),
        matching: find.text('1234 5678 '),
      ),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('bank-card-iridescent-edge'))),
      const Size(380, 200),
    );
    expect(find.text('UnionPay'), findsOneWidget);
    expect(selected.boxShadow, original.boxShadow);
    expect(tester.takeException(), isNull);
  });

  testWidgets('brand is stable across rebuilds and honors real type', (
    tester,
  ) async {
    Future<void> render(String? type) => tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: BankCardWidget(
            bankName: 'Bank',
            cardNumber: '****3232',
            ownerName: 'ALEX',
            expirationDate: '08/29',
            cardType: type,
            width: 380,
          ),
        ),
      ),
    );
    await render('UnionPay');
    expect(find.text('UnionPay'), findsOneWidget);
    await render('UnionPay');
    expect(find.text('UnionPay'), findsOneWidget);
    await render(null);
    final firstBrand = tester.widgetList<Text>(find.byType(Text)).last.data;
    for (var i = 0; i < 5; i++) {
      await render(null);
      expect(tester.widgetList<Text>(find.byType(Text)).last.data, firstBrand);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('long names preserve layout with narrow, wide and double text', (
    tester,
  ) async {
    for (final width in [320.0, 390.0, 520.0]) {
      for (final scale in [1.0, 2.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Center(
                child: BankCardWidget(
                  bankName: 'A very long international bank name 银行',
                  cardNumber: '**** **** **** 3232',
                  ownerName: 'ALEX VERY LONG OWNER NAME 持卡人',
                  expirationDate: '08/29',
                  cardType: 'MasterCard',
                  width: width,
                  height: scale == 1 ? 200 : 280,
                ),
              ),
            ),
          ),
        );
        expect(find.text('MasterCard'), findsOneWidget);
        expect(find.text('08/29'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
