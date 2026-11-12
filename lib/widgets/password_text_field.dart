import 'package:flutter/material.dart';
import 'package:sirc/core/localization/app_locale.dart';
import 'package:sirc/l10n/languages.g.dart';
import 'package:sirc/widgets/form_input_decoration.dart';

/// Shared password presentation without changing field validation or submission.
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.controller,
    this.errorText,
    this.isNewPassword = false,
    this.isVisible,
    this.onVisibilityChanged,
    this.enabled = true,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String? errorText;
  final bool isNewPassword;
  final bool enabled;
  final bool? isVisible;
  final ValueChanged<bool>? onVisibilityChanged;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final visible = widget.isVisible ?? _isVisible;
    final visibilityLabel = visible
        ? Languages.settings.hidePassword
        : Languages.settings.showPassword;
    return TextField(
      enabled: widget.enabled,
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: !visible,
      keyboardType: TextInputType.visiblePassword,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: [
        widget.isNewPassword
            ? AutofillHints.newPassword
            : AutofillHints.password,
      ],
      style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurface),
      decoration: formInputDecoration(
        context,
        label: widget.label,
        errorText: widget.errorText,
        suffixIcon: IconButton(
          tooltip: visibilityLabel,
          isSelected: visible,
          color: colors.onSurfaceVariant,
          icon: const Icon(Icons.visibility_outlined),
          selectedIcon: const Icon(Icons.visibility_off_outlined),
          onPressed: widget.enabled
              ? () {
                  setState(() => _isVisible = !visible);
                  widget.onVisibilityChanged?.call(!visible);
                }
              : null,
        ),
      ),
    );
  }
}
