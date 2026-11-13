import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/features/auth/presentation/password_page.dart';

void main() {
  for (final width in [375.0, 1461.0]) {
    testWidgets('修改密码页在宽度 $width 时顶部对齐并使用主题纯色按钮', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(() => tester.view.reset());
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PasswordPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(3));
      final appBarBottom = tester.getRect(find.byType(AppBar)).bottom;
      final firstFieldRect = tester.getRect(fields.first);
      expect(firstFieldRect.top - appBarBottom, closeTo(20, 0.01));
      final contentWidth = width.clamp(0.0, 520.0);
      final contentLeft = (width - contentWidth) / 2 + 20;
      expect(firstFieldRect.left, closeTo(contentLeft, 0.01));

      final buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsOneWidget);
      final buttonRect = tester.getRect(buttonFinder);
      expect(buttonRect.left, closeTo(contentLeft, 0.01));
      expect(buttonRect.width, closeTo(contentWidth - 40, 0.01));
      expect(buttonRect.height, closeTo(50, 0.01));
      expect(
        buttonRect.top - tester.getRect(fields.last).bottom,
        closeTo(24, 0.01),
      );
      final buttonMaterial = tester.widget<Material>(
        find.descendant(of: buttonFinder, matching: find.byType(Material)),
      );
      final theme = Theme.of(tester.element(buttonFinder));
      expect(buttonMaterial.color, theme.colorScheme.primary);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).gradient != null,
        ),
        findsNothing,
      );

      await tester.enterText(fields.first, 'old-password');
      await tester.pump();
      expect(tester.widget<FilledButton>(buttonFinder).onPressed, isNull);
      await tester.enterText(fields.at(1), 'new-password');
      await tester.enterText(fields.at(2), 'new-password');
      await tester.pump();
      expect(tester.widget<FilledButton>(buttonFinder).onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });
  }
}
