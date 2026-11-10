import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/features/auth/presentation/sign_up_page.dart';
import 'package:sirc/features/auth/presentation/sign_up_field.dart';

void main() {
  for (final dark in [false, true]) {
    for (final width in [320.0, 1440.0]) {
      testWidgets('注册柔灰 $dark / $width 保留字段标签、SVG、状态与显隐', (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: MaterialApp(
              theme: dark
                  ? ThemeData(brightness: Brightness.dark)
                  : AppTheme.lightTheme,
              home: const SignUpPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final fields = find.byType(TextField);
        expect(fields, findsNWidgets(4));
        expect(find.byType(SvgPicture), findsNWidgets(6));
        final first = tester.widget<TextField>(fields.first);
        expect(
          first.decoration!.fillColor,
          dark ? const Color(0xFF2C2C2C) : const Color(0xFFF2F2F2),
        );
        final border = first.decoration!.enabledBorder! as OutlineInputBorder;
        expect(border.borderRadius, BorderRadius.circular(14));
        expect(border.borderSide.color, Colors.transparent);
        final expectedInk = dark
            ? const Color(0xFFF2F2F2)
            : const Color(0xFF26282B);
        expect(
          (first.decoration!.focusedBorder! as OutlineInputBorder)
              .borderSide
              .color,
          expectedInk,
        );
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        final label = tester
            .widget<SignUpField>(find.byType(SignUpField).first)
            .label;
        expect(find.text(label), findsWidgets);
        await tester.enterText(fields.first, 'testuser');
        await tester.pumpAndSettle();
        expect(find.text(label), findsWidgets);
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText).first)
              .focusNode
              .hasFocus,
          isTrue,
        );
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is DecoratedBox &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).boxShadow?.isNotEmpty == true,
          ),
          findsWidgets,
        );
        await tester.enterText(fields.at(1), 'invalid');
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(fields.at(1)).decoration!.errorText,
          isNotNull,
        );
        await tester.enterText(fields.at(1), 'test@example.com');
        await tester.enterText(fields.at(2), 'Password123');
        await tester.enterText(fields.at(3), 'Password123');
        await tester.pumpAndSettle();
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNotNull,
        );
        expect(tester.widget<TextField>(fields.at(2)).obscureText, isTrue);
        final toggle = find.descendant(
          of: find.byType(SignUpField).at(2),
          matching: find.byType(IconButton),
        );
        expect(tester.widget<IconButton>(toggle).tooltip, isNotEmpty);
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(fields.at(2)).obscureText, isFalse);
        expect(tester.widget<TextField>(fields.at(3)).obscureText, isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('禁用注册字段不可输入或切换密码', (tester) async {
    var changes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignUpField(
            label: 'Password',
            onChanged: (_) => changes++,
            password: true,
            enabled: false,
          ),
        ),
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
    expect(field.decoration!.fillColor, const Color(0xFFF8F8F8));
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
    expect(changes, 0);
  });
}
