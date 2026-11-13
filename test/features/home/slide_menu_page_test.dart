import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/features/home/controllers/navigation_controller.dart';
import 'package:sirc/features/home/presentation/slide_menu_page.dart';

const _contentKey = ValueKey('slide-menu-content');
const _paneKey = ValueKey('slide-menu-pane');

void main() {
  late ProviderContainer container;
  late Locale originalLocale;

  setUp(() {
    originalLocale = AppLocale.currentLocale;
    AppLocale.setLocale(const Locale('en', 'US'));
    container = ProviderContainer();
    container.read(navigationControllerProvider.notifier).updateUserAvatar('');
  });

  tearDown(() {
    container.dispose();
    AppLocale.setLocale(originalLocale);
  });

  Future<void> pumpMenu(
    WidgetTester tester,
    Size size, {
    double textScale = 1,
    Widget? child,
    ValueChanged<int>? onSelected,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: SlideMenuPage(
            onBranchSelected: onSelected ?? (_) {},
            child: child ?? const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> openMenu(WidgetTester tester) async {
    container.read(navigationControllerProvider.notifier).openDrawer();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
  }

  Transform content(WidgetTester tester) =>
      tester.widget<Transform>(find.byKey(_contentKey));

  for (final width in [320.0, 390.0, 839.0, 840.0, 1200.0, 1600.0]) {
    testWidgets('$width width uses bounded menu and centered light scale', (
      tester,
    ) async {
      double? layoutWidth;
      await pumpMenu(
        tester,
        Size(width, 900),
        child: LayoutBuilder(
          builder: (context, constraints) {
            layoutWidth = constraints.maxWidth;
            return const SizedBox.expand();
          },
        ),
      );
      await openMenu(tester);
      final menuWidth = tester.getSize(find.byKey(_paneKey)).width;
      final matrix = content(tester).transform;
      final scale = width >= 840 ? .96 : .92;
      expect(menuWidth, lessThanOrEqualTo(320));
      expect(menuWidth, lessThanOrEqualTo(width - 88));
      expect(matrix.entry(0, 3), closeTo(menuWidth + 16, .001));
      expect(matrix.entry(0, 0), closeTo(scale, .001));
      expect(matrix.entry(1, 3), closeTo(900 * (1 - scale) / 2, .001));
      expect(width - matrix.entry(0, 3), greaterThanOrEqualTo(72));
      expect(layoutWidth, width);
      final shadow = tester.widget<Transform>(
        find.byKey(const ValueKey('slide-menu-shadow')),
      );
      expect(shadow.transform.entry(0, 3), greaterThanOrEqualTo(menuWidth));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('menu does not grow with wide window', (tester) async {
    await pumpMenu(tester, const Size(1200, 900));
    await openMenu(tester);
    final width = tester.getSize(find.byKey(_paneKey)).width;
    tester.view.physicalSize = const Size(1800, 900);
    await tester.pump();
    expect(tester.getSize(find.byKey(_paneKey)).width, width);
    expect(content(tester).transform.entry(0, 3), width + 16);
  });

  for (final width in [160.0, 320.0, 1200.0]) {
    testWidgets('$width width handles 2x text, long account and short height', (
      tester,
    ) async {
      container
          .read(navigationControllerProvider.notifier)
          .setUserInfo(
            name: 'A very long account display name for layout testing',
            email: '${List.filled(12, 'long-email').join()}@example.com',
          );
      await pumpMenu(tester, Size(width, 320), textScale: 2);
      await openMenu(tester);
      expect(
        tester.getSize(find.byKey(_paneKey)).width,
        lessThanOrEqualTo(width < 448 ? width - 88 : 360),
      );
      expect(tester.takeException(), isNull);
      final close = find.byIcon(Icons.exit_to_app_outlined);
      await tester.ensureVisible(close);
      await tester.pump();
      await tester.tap(close);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(
        container.read(navigationControllerProvider).isDrawerOpen,
        isFalse,
      );
      expect(content(tester).transform.isIdentity(), isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('visible content dismisses without passing tap to child', (
    tester,
  ) async {
    var taps = 0;
    await pumpMenu(
      tester,
      const Size(320, 700),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => taps++,
        child: const SizedBox.expand(),
      ),
    );
    await openMenu(tester);
    await tester.tapAt(const Offset(300, 350));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(container.read(navigationControllerProvider).isDrawerOpen, isFalse);
    expect(taps, 0);
    expect(content(tester).transform.isIdentity(), isTrue);
    await tester.tapAt(const Offset(300, 350));
    expect(taps, 1);
  });

  testWidgets('branch menu selection closes and preserves title format', (
    tester,
  ) async {
    int? selected;
    await pumpMenu(
      tester,
      const Size(390, 900),
      onSelected: (i) => selected = i,
    );
    await openMenu(tester);
    await tester.tap(find.text(' ${Languages.settings.title}'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(selected, 4);
    expect(container.read(navigationControllerProvider).isDrawerOpen, isFalse);
  });

  testWidgets(
    'opening, closing and resizing preserve content input and scroll',
    (tester) async {
      final text = TextEditingController();
      final scroll = ScrollController();
      addTearDown(text.dispose);
      addTearDown(scroll.dispose);
      await pumpMenu(
        tester,
        const Size(390, 700),
        child: SingleChildScrollView(
          controller: scroll,
          child: Column(
            children: [
              TextField(controller: text),
              const SizedBox(height: 1800),
            ],
          ),
        ),
      );
      final element = tester.element(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'kept input');
      FocusManager.instance.primaryFocus?.unfocus();
      // Finish TextField's deferred caret reveal before establishing scroll state.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      scroll.jumpTo(100);
      await tester.pump();
      await openMenu(tester);
      for (final width in [1200.0, 839.0, 840.0, 320.0]) {
        tester.view.physicalSize = Size(width, 700);
        await tester.pump();
        expect(
          identical(element, tester.element(find.byType(TextField))),
          isTrue,
        );
        expect(text.text, 'kept input');
        expect(scroll.offset, 100);
      }
      container.read(navigationControllerProvider.notifier).closeDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(text.text, 'kept input');
      expect(scroll.offset, 100);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
