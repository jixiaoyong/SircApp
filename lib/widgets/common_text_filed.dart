import 'package:flutter/material.dart';
import 'package:sirc/widgets/form_input_decoration.dart';

class CommonTextFiled extends StatelessWidget {
  final String label;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final String? errorText;
  final int? maxLength;
  final String? hint;
  final TextEditingController? controller;
  final Widget? suffixIcon;

  const CommonTextFiled({
    super.key,
    required this.label,
    this.hint,
    this.onChanged,
    this.keyboardType,
    this.errorText,
    this.maxLength,
    this.controller,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyLarge
          ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
      decoration: formInputDecoration(
        context,
        label: label,
        errorText: errorText,
        suffixIcon: suffixIcon,
      ).copyWith(hintText: hint),
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLength: maxLength,
    );
  }
}
