import 'package:flutter/material.dart';
import 'package:sirc/widgets/common_text_filed.dart';
import 'package:sirc/widgets/password_text_field.dart';

/// Registration keeps its public field API while sharing all form presentation.
class SignUpField extends StatelessWidget {
  const SignUpField({
    super.key,
    required this.label,
    required this.onChanged,
    this.errorText,
    this.keyboardType,
    this.icon = 'mail',
    this.password = false,
    this.enabled = true,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final String icon;
  final bool password;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (password) {
      return PasswordTextField(
        label: label,
        errorText: errorText,
        isNewPassword: true,
        enabled: enabled,
        onChanged: onChanged,
      );
    }
    return CommonTextFiled(
      label: label,
      errorText: errorText,
      keyboardType: keyboardType,
      enabled: enabled,
      suffixIcon: Icon(
        icon == 'user' ? Icons.person_outline : Icons.email_outlined,
      ),
      onChanged: onChanged,
    );
  }
}
