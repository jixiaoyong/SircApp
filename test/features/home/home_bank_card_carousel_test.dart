import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';

void main() {
  setUpAll(() => AppLocale.setLocale(const Locale('zh', 'CN')));

  void configureView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget harness(
    ProviderContainer container,
    double width, {
    double textScale = 1,
  }) => UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: const HomeBankCardCarousel()),
        ),
      ),
    ),
  );

  ScrollController controller(WidgetTester tester) => tester
      .widget<ListView>(find.byKey(const ValueKey('home-bank-scroll')))
      .controller!;

  testWidgets('窄屏首卡与宽屏整组居中、多卡可见且高度按比例变化', (tester) async {
    configureView(tester);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    for (final width in [390.0, 525.0, 800.0, 1200.0]) {
      await tester.pumpWidget(harness(container, width));
      await tester.pumpAndSettle();
      final cardWidth = width < 420 ? width * .9 : 360.0;
      final first = find.byKey(const ValueKey('home-bank-card-0'));
      final contentWidth = 3 * cardWidth + 2 * 18;
      final leading = contentWidth <= width
          ? (width - contentWidth) / 2
          : width < 420
          ? (width - cardWidth) / 2
          : 0.0;
      expect(tester.getRect(first).left, closeTo(leading, .01));
      expect(tester.getSize(first).width, cardWidth);
      expect(
        tester.getSize(find.byType(HomeBankCardCarousel)).height,
        closeTo(cardWidth * 200 / 380 + 38, .01),
      );
      expect(container.read(homeControllerProvider).currentBankIndex, 0);
      final displayed = tester
          .widgetList<BankCardWidget>(find.byType(BankCardWidget))
          .toList();
      final cards = container.read(walletControllerProvider).cards;
      for (final card in displayed) {
        final source = cards.firstWhere(
          (e) =>
              e.cardNumber.replaceAll(' ', '') ==
              card.cardNumber.replaceAll(' ', ''),
        );
        expect(card.cardType, source.cardType);
      }
      final viewport = tester.getRect(
        find.byKey(const ValueKey('home-bank-scroll')),
      );
      final surface = tester.getRect(
        find.descendant(
          of: first,
          matching: find.byKey(const ValueKey('bank-card-iridescent-edge')),
        ),
      );
      expect(surface.center.dy, closeTo(viewport.center.dy, .01));
      expect(surface.width, closeTo(cardWidth, .01));
      expect(surface.height, closeTo(cardWidth * 200 / 380, .01));
      if (width < 420) {
        expect(surface.center.dx, closeTo(viewport.center.dx, .01));
      }
      if (contentWidth <= width) {
        final last = tester.getRect(
          find.byKey(const ValueKey('home-bank-card-2')),
        );
        expect(
          (surface.left + last.right) / 2,
          closeTo(viewport.center.dx, .01),
        );
      }
      final visible =
          [
                for (var i = 0; i < 3; i++)
                  find.byKey(ValueKey('home-bank-card-$i')),
              ]
              .where(
                (f) =>
                    f.evaluate().isNotEmpty &&
                    tester.getRect(f).overlaps(viewport),
              )
              .length;
      expect(visible, width == 1200 ? 3 : greaterThanOrEqualTo(2));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('单卡在窄宽屏及大字下卡面双轴居中', (tester) async {
    configureView(tester);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(harness(container, 390));
    await tester.pumpAndSettle();
    final wallet = container.read(walletControllerProvider);
    container.read(walletControllerProvider.notifier).state = wallet.copyWith(
      cards: [wallet.cards.first],
      selectedCardIndex: 0,
    );
    for (final width in [320.0, 390.0, 800.0, 1200.0]) {
      await tester.pumpWidget(harness(container, width, textScale: 2));
      await tester.pumpAndSettle();
      final viewport = tester.getRect(
        find.byKey(const ValueKey('home-bank-scroll')),
      );
      final surface = tester.getRect(
        find.byKey(const ValueKey('bank-card-iridescent-edge')),
      );
      expect(surface.center.dx, closeTo(viewport.center.dx, .01));
      expect(surface.center.dy, closeTo(viewport.center.dy, .01));
      expect(controller(tester).position.maxScrollExtent, 0);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('点击最小滚动、拖动结束选择且resize保持合法选中', (tester) async {
    configureView(tester);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(harness(container, 1200));
    await tester.pumpAndSettle();
    final original = controller(tester);
    await tester.tap(find.byKey(const ValueKey('home-bank-card-2')));
    await tester.pumpAndSettle();
    expect(container.read(homeControllerProvider).currentBankIndex, 2);
    expect(controller(tester).offset, 0); // 全部可见时不额外挪动。
    for (final width in [390.0, 526.0, 800.0, 1200.0, 390.0]) {
      await tester.pumpWidget(harness(container, width));
      await tester.pumpAndSettle();
      expect(controller(tester), same(original));
      expect(container.read(homeControllerProvider).currentBankIndex, 2);
      final last = tester.getRect(
        find.byKey(const ValueKey('home-bank-card-2')),
      );
      final viewport = tester.getRect(
        find.byKey(const ValueKey('home-bank-scroll')),
      );
      expect(last.right, lessThanOrEqualTo(viewport.right + .1));
      if (width < 420) {
        expect(last.center.dx, closeTo(viewport.center.dx, .01));
      }
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.byKey(const ValueKey('bank-card-indicator-0')));
    await tester.pumpAndSettle();
    expect(controller(tester).offset, 0);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('home-bank-scroll'))),
    );
    await gesture.moveBy(const Offset(-30, 0));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(-250, 0));
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(homeControllerProvider).currentBankIndex, 0);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(container.read(homeControllerProvider).currentBankIndex, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(() => original.addListener(() {}), throwsFlutterError);
  });
}
