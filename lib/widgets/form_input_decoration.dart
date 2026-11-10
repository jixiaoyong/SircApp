import 'package:flutter/material.dart';

/// Local form styling shared by account and card fields, not the global theme.
InputDecoration formInputDecoration(
  BuildContext context, {
  required String label,
  String? errorText,
  Widget? suffixIcon,
}) {
  final colors = Theme.of(context).colorScheme;
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );
  return InputDecoration(
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: TextStyle(color: colors.onSurfaceVariant),
    floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
      return TextStyle(
        color: states.contains(WidgetState.error)
            ? colors.error
            : states.contains(WidgetState.focused)
            ? colors.primary
            : colors.onSurfaceVariant,
      );
    }),
    filled: true,
    fillColor: colors.surfaceContainerLow,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(colors.outlineVariant, 1),
    enabledBorder: border(colors.outlineVariant, 1),
    focusedBorder: border(colors.primary, 1.5),
    errorBorder: border(colors.error, 1),
    focusedErrorBorder: border(colors.error, 1.5),
    errorText: errorText,
    errorMaxLines: 3,
    suffixIcon: suffixIcon,
  );
}
