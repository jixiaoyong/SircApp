import 'package:flutter/material.dart';
import 'package:sirc/utils/size_extension.dart';

class CommonTextFiled extends StatelessWidget {
  final String label;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final String? errorText;
  final int? maxLength;

  String? hint;

  CommonTextFiled({
    Key? key,
    required this.label,
    this.hint,
    this.onChanged,
    this.keyboardType,
    this.errorText,
    this.maxLength,
  }) : super(key: key) {
    hint = hint ?? label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.dp),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, offset: Offset(0, 4), blurRadius: 8)
          ],
          color: Colors.white),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.black12, width: 0),
          ),
          labelText: label,
          errorText: errorText,
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        maxLength: maxLength,
      ),
    );
  }
}
