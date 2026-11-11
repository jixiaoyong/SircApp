import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/core/layout/adaptive_detail_layout.dart';
import 'package:sirc/features/home/presentation/menu_page.dart';
import 'package:sirc/widgets/settings_item_tile.dart';

void main() {
  testWidgets('详情在 839/840 断点往返保留输入与滚动状态', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final scrollController = ScrollController();
    final textController = TextEditingController();
    addTearDown(scrollController.dispose);
    addTearDown(textController.dispose);
    final detail = SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          TextField(controller: textController),
          const SizedBox(height: 1600),
        ],
      ),
    );
    for (final width in [1200.0, 839.0, 840.0, 390.0, 1200.0]) {
      tester.view.physicalSize = Size(width, 600);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveDetailLayout(
              hasDetail: true,
              primary: const SizedBox.expand(),
              primaryPaneKey: const ValueKey('menu-pane'),
              detail: detail,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (textController.text.isEmpty) {
        await tester.enterText(find.byType(TextField), 'keep input');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        scrollController.jumpTo(180);
        await tester.pump();
      }
      expect(textController.text, 'keep input');
      expect(scrollController.offset, 180);
      expect(
        find.byKey(const ValueKey('menu-pane')),
        width >= 840 ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
  for (final dark in [false, true]) {
    testWidgets('菜单 ${dark ? '暗色' : '亮色'} 整行与开关各切换一次且登出需确认', (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: const Scaffold(body: MenuPage()),
          ),
        ),
      );
      final fingerprint = find.byWidgetPredicate(
        (widget) =>
            widget is SettingsItemTile &&
            widget.icon == Icons.fingerprint_outlined,
      );
      expect(container.read(fingerprintEnabledProvider), isFalse);
      await tester.tap(
        find.descendant(
          of: fingerprint,
          matching: find.byType(CupertinoSwitch),
        ),
      );
      await tester.pumpAndSettle();
      expect(container.read(fingerprintEnabledProvider), isTrue);
      await tester.tap(
        find.descendant(of: fingerprint, matching: find.byType(Text)).first,
      );
      await tester.pumpAndSettle();
      expect(container.read(fingerprintEnabledProvider), isFalse);
      final logout = find.byWidgetPredicate(
        (widget) => widget is SettingsItemTile && widget.icon == Icons.logout,
      );
      await tester.ensureVisible(logout);
      await tester.tap(logout);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(Languages.sureToLogout), findsOneWidget);
      await tester.tap(find.text(Languages.cancel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(MenuPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
