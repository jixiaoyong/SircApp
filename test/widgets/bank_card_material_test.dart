import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/widgets/bank_card_widget.dart';

void main() {
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
