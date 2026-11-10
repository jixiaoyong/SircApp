import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/features/auth/presentation/sign_in_page.dart';
import 'package:sirc/features/auth/presentation/sign_up_page.dart';
import 'package:sirc/widgets/constrained_content.dart';
import 'package:sirc/features/auth/presentation/forget_pwd_page.dart';
import 'package:sirc/features/auth/presentation/set_pwd_page.dart';
import 'package:sirc/features/wallet/presentation/add_card_page.dart';
import 'package:sirc/widgets/common_text_filed.dart';
import 'package:sirc/widgets/common_text_button.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('普通输入在 $brightness 持续标签并响应主题焦点和错误', (tester) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        ),
      );
      String? error;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return CommonTextFiled(label: 'Email', errorText: error);
              },
            ),
          ),
        ),
      );
      final fieldFinder = find.byType(TextField);
      final decoration = tester.widget<TextField>(fieldFinder).decoration!;
      expect(decoration.floatingLabelBehavior, FloatingLabelBehavior.always);
      expect(decoration.fillColor, theme.colorScheme.surfaceContainerHighest);
      expect(
        (decoration.enabledBorder! as OutlineInputBorder).borderSide.color,
        theme.colorScheme.outline,
      );
      expect(
        (decoration.focusedBorder! as OutlineInputBorder).borderSide.color,
        theme.colorScheme.secondary,
      );
      await tester.enterText(fieldFinder, 'invalid');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
      update(() => error = 'Invalid email');
      await tester.pumpAndSettle();
      final updated = tester.widget<TextField>(fieldFinder).decoration!;
      expect(find.text('Invalid email'), findsOneWidget);
      expect(
        (updated.focusedErrorBorder! as OutlineInputBorder).borderSide.color,
        theme.colorScheme.error,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('共享提交按钮纯色、启禁与回调保持一致', (tester) async {
    var enabled = false;
    var taps = 0;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return CommonTextButton(
                isButtonEnabled: enabled,
                onTap: () => taps++,
                text: 'Submit',
              );
            },
          ),
        ),
      ),
    );
    final button = find.byType(FilledButton);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    update(() => enabled = true);
    await tester.pumpAndSettle();
    final material = tester.widget<Material>(
      find.descendant(of: button, matching: find.byType(Material)),
    );
    expect(material.color, AppTheme.lightTheme.colorScheme.primary);
    await tester.tap(button);
    expect(taps, 1);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).gradient != null,
      ),
      findsNothing,
    );
  });

  for (final width in [320.0, 1461.0]) {
    for (final page in <Widget>[
      const SignInPage(),
      const SignUpPage(),
      const ForgetPwdPage(),
      const SetPwdPage(),
      const AddCardPage(),
    ]) {
      testWidgets('${page.runtimeType} 宽度 $width 局部限宽、对齐且键盘下可滚动', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: MaterialApp(theme: AppTheme.lightTheme, home: page),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        final fields = find.byType(TextField);
        final rect = tester.getRect(fields.first);
        final contentWidth = width.clamp(0.0, 520.0);
        expect(rect.width, closeTo(contentWidth - 40, .01));
        expect(rect.left, closeTo((width - contentWidth) / 2 + 20, .01));
        if (page is SignInPage || page is SignUpPage) {
          expect(find.byType(AppBar), findsNothing);
          final content = tester.getRect(find.byType(ConstrainedContent));
          final viewport = tester.getRect(find.byType(SingleChildScrollView));
          expect(content.center.dy, closeTo(viewport.center.dy, .01));
        } else if (page is SetPwdPage) {
          expect(
            rect.top - tester.getRect(find.byType(AppBar)).bottom,
            closeTo(20, .01),
          );
        }
        expect(find.byType(FilledButton), findsOneWidget);
        tester.view.viewInsets = const FakeViewPadding(bottom: 500);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.ensureVisible(find.byType(FilledButton));
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
