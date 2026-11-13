import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/widgets/password_text_field.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('密码框在 $brightness 保留标签、焦点、错误和安全显隐', (tester) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        ),
      );
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      String? error;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return PasswordTextField(
                  label: '密码',
                  controller: controller,
                  errorText: error,
                  isNewPassword: true,
                  onChanged: (_) {},
                );
              },
            ),
          ),
        ),
      );
      var field = tester.widget<TextField>(find.byType(TextField));
      final decoration = field.decoration!;
      expect(decoration.labelText, '密码');
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
      expect(field.obscureText, isTrue);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.autofillHints, [AutofillHints.newPassword]);
      await tester.enterText(find.byType(TextField), 'test-password');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
      final semantics = tester.ensureSemantics();
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isFalse);
      expect(controller.text, 'test-password');
      expect(
        tester.widget<IconButton>(find.byType(IconButton)).tooltip,
        isNotEmpty,
      );
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isTrue,
      );
      update(() => error = '密码不匹配');
      await tester.pumpAndSettle();
      expect(find.text('密码不匹配'), findsOneWidget);
      field = tester.widget<TextField>(find.byType(TextField));
      expect(
        (field.decoration!.focusedErrorBorder! as OutlineInputBorder)
            .borderSide
            .color,
        theme.colorScheme.error,
      );
      expect(controller.text, 'test-password');
      semantics.dispose();
      expect(tester.takeException(), isNull);
    });
  }
}
