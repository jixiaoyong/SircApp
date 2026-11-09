import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/home_controller.dart';
import 'package:sirc/features/home/presentation/home_page.dart';
import 'package:sirc/widgets/bank_card_widget.dart';

// Ahem 测试字体的每个字符等宽；用短日期隔离银行卡内部文字布局，
// 本测试只验证轮播约束、选择与控制器生命周期。
class _CarouselHomeController extends HomeController {
  @override
  HomeState build() {
    final initial = super.build();
    return initial.copyWith(
      banks: initial.banks
          .map((card) => BankCardItem(
                bankName: card.bankName,
                cardNumber: card.cardNumber,
                ownerName: card.ownerName,
                expirationDate: '1/1',
              ))
          .toList(),
    );
  }
}

ProviderContainer _container() => ProviderContainer(overrides: [
      homeControllerProvider.overrideWith(_CarouselHomeController.new),
    ]);

void main() {
  setUpAll(() {
    AppLocale.setLocale(const Locale('zh', 'CN'));
  });

  void configureView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget harness(ProviderContainer container, double width) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              child: const HomeBankCardCarousel(),
            ),
          ),
        ),
      ),
    );
  }

  PageController controller(WidgetTester tester) =>
      tester.widget<PageView>(find.byType(PageView)).controller!;

  testWidgets('uses parent width, caps card width and keeps height fixed',
      (tester) async {
    configureView(tester);
    final container = _container();
    addTearDown(container.dispose);

    for (final width in [390.0, 525.0, 526.0, 1200.0]) {
      await tester.pumpWidget(harness(container, width));
      await tester.pump();
      final pageWidth = (width * 0.8).clamp(0.0, 420.0);
      expect(controller(tester).viewportFraction,
          closeTo(pageWidth / width, 1e-9));
      final card = find.byType(BankCardWidget).first;
      expect(tester.getSize(card).width, closeTo(pageWidth - 20, 1e-6));
      expect(tester.getSize(card).height, 200);
      expect(tester.getSize(find.byType(HomeBankCardCarousel)).height, 255);

      final viewport = tester.getRect(find.byType(PageView));
      final visibleCards = tester
          .widgetList<BankCardWidget>(find.byType(BankCardWidget))
          .where((widget) =>
              tester.getRect(find.byWidget(widget)).overlaps(viewport))
          .length;
      expect(visibleCards, width == 1200 ? greaterThanOrEqualTo(2) : 2);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('snaps by one card and dots select each card after resizing',
      (tester) async {
    configureView(tester);
    final container = _container();
    addTearDown(container.dispose);
    await tester.pumpWidget(harness(container, 390));

    await tester.timedDrag(find.byType(PageView), const Offset(-200, 0),
        const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(controller(tester).page, closeTo(1, 1e-6));
    expect(container.read(homeControllerProvider).currentBankIndex, 1);

    final oldController = controller(tester);
    await tester.pumpWidget(harness(container, 1200));
    await tester.pump();
    expect(controller(tester), isNot(same(oldController)));
    expect(controller(tester).page, closeTo(1, 1e-6));
    expect(container.read(homeControllerProvider).currentBankIndex, 1);
    expect(() => oldController.addListener(() {}), throwsFlutterError);

    for (final index in [2, 0, 1]) {
      await tester.tap(find.byKey(ValueKey('bank-card-indicator-$index')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(controller(tester).page, closeTo(index.toDouble(), 1e-6));
      expect(container.read(homeControllerProvider).currentBankIndex, index);
    }

    await tester.timedDrag(find.byType(PageView), const Offset(-260, 0),
        const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(controller(tester).page, closeTo(2, 1e-6));

    for (final width in [800.0, 526.0, 525.0, 390.0]) {
      await tester.pumpWidget(harness(container, width));
      await tester.pump();
      expect(controller(tester).page, closeTo(2, 1e-6));
      expect(container.read(homeControllerProvider).currentBankIndex, 2);
      expect(tester.takeException(), isNull);
    }
    final lastController = controller(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(() => lastController.addListener(() {}), throwsFlutterError);
    expect(tester.takeException(), isNull);
  });
}
