import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sirc/widgets/common_text_filed.dart';
import 'package:sirc/widgets/password_text_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirc/core/storage/storage_service.dart';
import 'package:sirc/core/theme/app_theme.dart';
import 'package:sirc/features/auth/presentation/sign_up_page.dart';
import 'package:sirc/features/auth/presentation/sign_up_field.dart';
import 'package:sirc/features/auth/presentation/sign_in_page.dart';
import 'package:sirc/features/auth/presentation/forget_pwd_page.dart';
import 'package:sirc/features/auth/presentation/set_pwd_page.dart';
import 'package:sirc/features/auth/presentation/password_page.dart';
import 'package:sirc/widgets/constrained_content.dart';

void main() {
  for (final page in [const SignInPage(), const SignUpPage()]) {
    for (final width in [320.0, 390.0, 1200.0]) {
      for (final keyboard in [false, true]) {
        testWidgets('${page.runtimeType} 居中与滚动 $width / 键盘$keyboard', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();
          await tester.pumpWidget(
            ProviderScope(
              overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
              child: MaterialApp(
                theme: AppTheme.lightTheme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(keyboard ? 2 : 1),
                    viewInsets: EdgeInsets.only(bottom: keyboard ? 650 : 0),
                    padding: const EdgeInsets.only(top: 24, bottom: 20),
                  ),
                  child: child!,
                ),
                home: page,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(AppBar), findsNothing);
          expect(find.byType(BackButton), findsNothing);
          final content = tester.getRect(find.byType(ConstrainedContent));
          final viewport = tester.getRect(find.byType(SingleChildScrollView));
          if (!keyboard) {
            expect(content.height, lessThan(viewport.height));
            expect(content.center.dy, closeTo(viewport.center.dy, 1));
          } else {
            final scrollable = find
                .descendant(
                  of: find.byType(SingleChildScrollView),
                  matching: find.byType(Scrollable),
                )
                .first;
            final position = tester.state<ScrollableState>(scrollable).position;
            expect(position.maxScrollExtent, greaterThan(0));
            await tester.drag(
              find.byType(SingleChildScrollView),
              const Offset(0, -900),
            );
            await tester.pumpAndSettle();
            expect(position.pixels, greaterThan(0));
          }
          expect(
            tester.getSize(find.byType(TextField).first).width,
            lessThanOrEqualTo(480),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('App内修改密码保留顶部与返回', (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(home: PasswordPage(onBack: () {})),
      ),
    );
    await tester.pumpAndSettle();
    final viewport = tester.getRect(find.byType(SingleChildScrollView));
    final content = tester.getRect(find.byType(ConstrainedContent));
    expect(content.top, viewport.top);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final dark in [false, true]) {
    for (final page in <Widget>[
      const SignInPage(),
      const SignUpPage(),
      const ForgetPwdPage(),
      const SetPwdPage(initialUserName: 'test@example.com'),
      const PasswordPage(),
    ]) {
      testWidgets('${page.runtimeType} 跟随主题 $dark 且窄屏无溢出', (tester) async {
        tester.view.physicalSize = const Size(320, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: MaterialApp(
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              home: page,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final theme = Theme.of(tester.element(find.byType(TextField).first));
        expect(theme.brightness, dark ? Brightness.dark : Brightness.light);
        for (final field in tester.widgetList<TextField>(
          find.byType(TextField),
        )) {
          expect(
            field.decoration!.fillColor,
            theme.colorScheme.surfaceContainerHighest,
          );
          expect(
            (field.decoration!.enabledBorder! as OutlineInputBorder)
                .borderRadius,
            BorderRadius.circular(14),
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final dark in [false, true]) {
    for (final width in [320.0, 1440.0]) {
      testWidgets('注册柔灰 $dark / $width 复用公共字段并保留标签、状态与显隐', (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: MaterialApp(
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              home: const SignUpPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final fields = find.byType(TextField);
        expect(fields, findsNWidgets(4));
        expect(find.byType(CommonTextFiled), findsNWidgets(2));
        expect(find.byType(PasswordTextField), findsNWidgets(2));
        final colors = Theme.of(tester.element(fields.first)).colorScheme;
        final first = tester.widget<TextField>(fields.first);
        expect(first.decoration!.fillColor, colors.surfaceContainerHighest);
        final border = first.decoration!.enabledBorder! as OutlineInputBorder;
        expect(border.borderRadius, BorderRadius.circular(14));
        expect(border.borderSide.color, colors.outline);
        expect(
          (first.decoration!.focusedBorder! as OutlineInputBorder)
              .borderSide
              .color,
          colors.secondary,
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
          findsNothing,
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
    expect(
      field.decoration!.fillColor,
      Theme.of(tester.element(find.byType(TextField)))
          .colorScheme
          .surfaceContainerHighest,
    );
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
    expect(changes, 0);
  });
}
