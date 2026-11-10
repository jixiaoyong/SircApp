import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sirc/core/localization/app_locale.dart';

/// The selected HTML proposal, scoped to registration rather than all forms.
class SignUpField extends StatefulWidget {
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
  State<SignUpField> createState() => _SignUpFieldState();
}

class _SignUpFieldState extends State<SignUpField> {
  bool _visible = false;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFF2F2F2) : const Color(0xFF26282B);
    final muted = dark ? const Color(0xFFB3B3B3) : const Color(0xFF777B80);
    final error = dark ? const Color(0xFFFFA6A6) : const Color(0xFFB23D3D);
    final english = AppLocale.currentLocale.languageCode == 'en';
    final visibilityLabel = english
        ? '${_visible ? 'Hide' : 'Show'} ${widget.label.toLowerCase()}'
        : '${_visible ? '隐藏' : '显示'}${widget.label}';
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ink,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: _focus.hasFocus && widget.enabled
                ? [
                    BoxShadow(
                      color: ink.withValues(alpha: .13),
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Semantics(
            label: widget.label,
            child: TextField(
              focusNode: _focus,
              enabled: widget.enabled,
              onChanged: widget.onChanged,
              obscureText: widget.password && !_visible,
              keyboardType: widget.password
                  ? TextInputType.visiblePassword
                  : widget.keyboardType,
              autocorrect: !widget.password,
              enableSuggestions: !widget.password,
              autofillHints: widget.password
                  ? const [AutofillHints.newPassword]
                  : null,
              cursorColor: ink,
              style: TextStyle(
                fontSize: 13,
                color: widget.enabled ? ink : muted,
              ),
              decoration: InputDecoration(
                hintText: widget.label,
                hintStyle: TextStyle(color: muted),
                filled: true,
                fillColor: widget.enabled
                    ? (dark ? const Color(0xFF2C2C2C) : const Color(0xFFF2F2F2))
                    : (dark
                          ? const Color(0xFF242424)
                          : const Color(0xFFF8F8F8)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 17,
                ),
                border: border(Colors.transparent),
                enabledBorder: border(Colors.transparent),
                disabledBorder: border(Colors.transparent),
                focusedBorder: border(ink),
                errorBorder: border(error),
                focusedErrorBorder: border(error),
                errorText: widget.errorText,
                errorStyle: TextStyle(color: error, fontSize: 11),
                errorMaxLines: 3,
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: SignUpLineIcon(
                    name: widget.password ? 'lock' : widget.icon,
                    color: muted,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 20,
                ),
                suffixIcon: widget.password
                    ? IconButton(
                        tooltip: visibilityLabel,
                        isSelected: _visible,
                        onPressed: widget.enabled
                            ? () => setState(() => _visible = !_visible)
                            : null,
                        icon: SignUpLineIcon(
                          name: _visible ? 'eyeOff' : 'eye',
                          color: muted,
                          size: 18,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SignUpLineIcon extends StatelessWidget {
  const SignUpLineIcon({
    super.key,
    required this.name,
    required this.color,
    this.size = 20,
  });
  final String name;
  final Color color;
  final double size;

  static const paths = {
    'mail': '<rect x="3" y="5" width="18" height="14" rx="3"/><path d="m4 7 8 6 8-6"/>',
    'user':
        '<circle cx="12" cy="8" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/>',
    'lock': '<rect x="5" y="10" width="14" height="11" rx="3"/><path d="M8 10V7a4 4 0 0 1 8 0v3M12 14v3"/>',
    'eye': '<path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6S2 12 2 12Z"/><circle cx="12" cy="12" r="2.7"/>',
    'eyeOff': '<path d="m3 3 18 18M9.8 6.2A13 13 0 0 1 12 6c6.5 0 10 6 10 6a19 19 0 0 1-3 3.6M6.3 6.3A20 20 0 0 0 2 12s3.5 6 10 6a13 13 0 0 0 5.1-1M10 10a2.8 2.8 0 0 0 4 4"/>',
  };

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#777b80" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round">${paths[name]}</svg>',
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    excludeFromSemantics: true,
  );
}
