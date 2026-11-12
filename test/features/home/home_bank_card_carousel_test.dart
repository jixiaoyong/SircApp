import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/widgets/bank_card_widget.dart';
import 'package:sirc/mock/mock_data_repository.dart';
import 'package:sirc/features/wallet/presentation/controllers/wallet_controller.dart';

void main() {
  late MockDataRepository mock;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppLocale.setLocale(const Locale('zh', 'CN'));
    mock = MockDataRepository();
    await mock.wallet;
    await mock.articles;
  });

  void configureView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget harness(
    ProviderContainer container,
    double width, {
    double textScale = 1,
    bool disableAnimations = false,
  }) => UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
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
    final container = ProviderContainer(
      overrides: [mockDataRepositoryProvider.overrideWithValue(mock)],
    );
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
        closeTo(cardWidth * 200 / 380 + 22, .01),
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

  BankCardWidget selectedCard(WidgetTester tester) => tester
      .widgetList<BankCardWidget>(find.byType(BankCardWidget))
      .singleWhere((card) => card.isSelected);

  testWidgets('移除短条且选择仅扫光一次，重建不重播并保留品牌和语义', (tester) async {
    configureView(tester);
    final container = ProviderContainer(
      overrides: [mockDataRepositoryProvider.overrideWithValue(mock)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(harness(container, 1200));
    await tester.pumpAndSettle();
    expect(selectedCard(tester).selectionHighlightProgress, isNull);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxWidth == 32 &&
            widget.constraints?.maxHeight == 3,
      ),
      findsNothing,
    );
    final brands = container
        .read(walletControllerProvider)
        .cards
        .map((card) => card.cardType)
        .toList();
    await tester.tap(find.byKey(const ValueKey('home-bank-card-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final progress = selectedCard(tester).selectionHighlightProgress!;
    expect(progress, closeTo(200 / 650, .01));
    await tester.tap(find.byKey(const ValueKey('home-bank-card-1')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      selectedCard(tester).selectionHighlightProgress,
      greaterThan(progress),
    );
    await tester.pump(const Duration(milliseconds: 350));
    expect(selectedCard(tester).selectionHighlightProgress, isNull);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.selected == true,
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(harness(container, 800, textScale: 2));
    AppLocale.setLocale(const Locale('en', 'US'));
    await tester.pumpWidget(harness(container, 1200));
    await tester.pump();
    expect(selectedCard(tester).selectionHighlightProgress, isNull);
    expect(
      tester
          .widgetList<BankCardWidget>(find.byType(BankCardWidget))
          .map((card) => card.cardType)
          .toList(),
      brands,
    );
    AppLocale.setLocale(const Locale('zh', 'CN'));
    container.read(walletControllerProvider.notifier).selectCard(2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(selectedCard(tester).selectionHighlightProgress, greaterThan(0));
    // Dispose while the ticker is active.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('减少动画不扫光，途中开启立即停止且关闭后不补播', (tester) async {
    configureView(tester);
    final container = ProviderContainer(
      overrides: [mockDataRepositoryProvider.overrideWithValue(mock)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(harness(container, 1200, disableAnimations: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-bank-card-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(selectedCard(tester).isSelected, isTrue);
    expect(selectedCard(tester).selectionHighlightProgress, isNull);
    await tester.pumpWidget(harness(container, 1200));
    expect(selectedCard(tester).selectionHighlightProgress, isNull);
    container.read(walletControllerProvider.notifier).selectCard(2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(selectedCard(tester).selectionHighlightProgress, greaterThan(0));
    await tester.pumpWidget(harness(container, 1200, disableAnimations: true));
    expect(selectedCard(tester).selectionHighlightProgress, isNull);
    await tester.pumpWidget(harness(container, 1200));
    await tester.pump(const Duration(milliseconds: 100));
    expect(selectedCard(tester).selectionHighlightProgress, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('单卡在窄宽屏及大字下卡面双轴居中', (tester) async {
    configureView(tester);
    final container = ProviderContainer(
      overrides: [mockDataRepositoryProvider.overrideWithValue(mock)],
    );
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
    final container = ProviderContainer(
      overrides: [mockDataRepositoryProvider.overrideWithValue(mock)],
    );
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
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 100));
    expect(selectedCard(tester).selectionHighlightProgress, isNotNull);
    await tester.pumpAndSettle();
    expect(selectedCard(tester).selectionHighlightProgress, isNull);
    expect(container.read(homeControllerProvider).currentBankIndex, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(() => original.addListener(() {}), throwsFlutterError);
  });
}
