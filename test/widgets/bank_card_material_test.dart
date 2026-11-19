import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/wallet/domain/models/bank_card.dart';
import 'package:sirc/features/wallet/presentation/card_brand_label.dart';

void main() {
  late Locale originalLocale;
  setUp(() {
    originalLocale = AppLocale.currentLocale;
    AppLocale.setLocale(const Locale('en', 'US'));
  });
  tearDown(() => AppLocale.setLocale(originalLocale));

  BankCardWidget card(String number, {bool mask = false}) => BankCardWidget(
    bankName: 'Bank',
    cardNumber: number,
    ownerName: 'Owner',
    expirationDate: '08/29',
    maskCardNumber: mask,
  );

  test('卡号默认完整展示，仅显式开启时隐藏中间数字', () {
    expect(
      card('4929 1234 0000 0042').cardNumber.trim(),
      '4929 1234 0000 0042',
    );
    expect(
      card('4929 1234 0000 0042', mask: true).cardNumber.trim(),
      '4929 **** **** 0042',
    );
    expect(
      card('6222123456789012345', mask: true).cardNumber.trim(),
      '6222 **** **** ***2 345',
    );
    expect(
      card('**** **** **** 0042', mask: true).cardNumber.trim(),
      '**** **** **** 0042',
    );
    expect(card('4929', mask: true).cardNumber.trim(), '4929');
  });

  testWidgets('已知品牌和字段标签中英中切换且原始数据和未知品牌不变', (tester) async {
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
      expect(find.text(language == 'zh' ? '维萨卡' : 'Visa'), findsNWidgets(2));
      expect(
        find.text(language == 'zh' ? '万事达卡' : 'MasterCard'),
        findsOneWidget,
      );
      expect(find.text(Languages.wallet.nameOnCard), findsNWidgets(4));
      expect(find.text(Languages.wallet.expireDate), findsNWidgets(4));
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

  for (final brightness in Brightness.values) {
    testWidgets('$brightness 使用纯色细边框、右置芯片且无渐变阴影扫光', (tester) async {
      final dark = brightness == Brightness.dark;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Center(
            child: BankCardWidget(
              bankName: 'Sirc Bank',
              cardNumber: '4929123400003232',
              ownerName: 'ALEX CHEN',
              expirationDate: '08/29',
              cardType: 'MasterCard',
              width: 380,
            ),
          ),
        ),
      );
      final surface = find.byKey(const ValueKey('bank-card-flat-surface'));
      final decoration =
          tester.widget<Container>(surface).decoration! as BoxDecoration;
      expect(
        decoration.color,
        dark ? const Color(0xFF252C35) : const Color(0xFFFAFBFC),
      );
      expect(decoration.gradient, isNull);
      expect(decoration.boxShadow, isNull);
      expect(decoration.borderRadius, BorderRadius.circular(10));
      expect((decoration.border! as Border).top.width, 1);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(
        find.descendant(of: surface, matching: find.byType(CustomPaint)),
        findsNothing,
      );
      expect(find.byType(Image), findsNothing);
      expect(tester.getSize(surface), const Size(380, 200));
      expect(
        tester.getCenter(find.byKey(const ValueKey('bank-card-chip'))).dx,
        greaterThan(tester.getCenter(surface).dx),
      );
      expect(find.text('•• 3232'), findsOneWidget);
      expect(find.text('4929 1234 0000 3232 '), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Sirc Bank')).style!.color,
        dark ? const Color(0xFFEEF1F6) : const Color(0xFF232B36),
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('bank-card-tail'))).dy -
            tester.getTopLeft(surface).dy,
        lessThan(24),
      );
      expect(find.byType(Divider), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('选中只加强细边框，兼容旧进度但不绘制扫光或改变尺寸', (tester) async {
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
    BoxDecoration decoration() =>
        tester
                .widget<Container>(
                  find.byKey(const ValueKey('bank-card-flat-surface')),
                )
                .decoration!
            as BoxDecoration;
    await render();
    final original = decoration();
    await render(selected: true, progress: .5);
    final selected = decoration();
    expect(selected.color, original.color);
    expect(selected.border, isNot(original.border));
    expect(selected.gradient, isNull);
    expect(selected.boxShadow, isNull);
    expect(
      find.descendant(
        of: find.byType(BankCardWidget),
        matching: find.byType(CustomPaint),
      ),
      findsNothing,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('bank-card-flat-surface'))),
      const Size(380, 200),
    );
    expect(find.text('UnionPay'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('尾号不替代完整卡号，打码不修改原始模型', (tester) async {
    final source = BankCard(
      id: 'real-card',
      bankName: 'Bank',
      cardNumber: '4929123400000042',
      ownerName: 'Owner',
      expirationDate: '08/29',
      cardType: 'UnionPay',
    );
    final before = source.toJson();
    for (final masked in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: BankCardWidget(
              bankName: source.bankName,
              cardNumber: source.cardNumber,
              ownerName: source.ownerName,
              expirationDate: source.expirationDate,
              cardType: source.cardType,
              maskCardNumber: masked,
              width: 380,
            ),
          ),
        ),
      );
      expect(find.text('•• 0042'), findsOneWidget);
      expect(
        find.text(masked ? '4929 **** **** 0042 ' : '4929 1234 0000 0042 '),
        findsOneWidget,
      );
      expect(source.toJson(), before);
    }
    expect(
      BankCardWidget.fromCard(source).cardNumber.trim(),
      '4929 1234 0000 0042',
    );
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
    await render(null);
    final firstBrand = tester.widgetList<Text>(find.byType(Text)).last.data;
    for (var i = 0; i < 5; i++) {
      await render(null);
      expect(tester.widgetList<Text>(find.byType(Text)).last.data, firstBrand);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('亮暗主题长银行名和姓名在320px及双倍字体下无溢出', (tester) async {
    for (final brightness in Brightness.values) {
      for (final width in [320.0, 390.0, 520.0]) {
        for (final scale in [1.0, 2.0]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Center(
                  child: BankCardWidget(
                    bankName: 'A very long international bank name 银行',
                    cardNumber: '6222123456789012345',
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
    }
  });
}
