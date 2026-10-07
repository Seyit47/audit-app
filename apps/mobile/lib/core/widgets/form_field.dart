import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// Label (+ red asterisk) above a control, from the add-shop form (`252:26487` / `101:2472`).
class AppFormField extends StatelessWidget {
  const AppFormField({super.key, required this.label, required this.child, this.required = false, this.error, this.valid = false});

  final String label;
  final Widget child;
  final bool required;
  final String? error;
  /// The green check of the filled form (`252:26607`).
  final bool valid;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Flexible(
            child: Text.rich(TextSpan(text: label, children: [
              if (required) TextSpan(text: ' *', style: TextStyle(color: c.error, fontWeight: FontWeight.w700)),
            ]), style: AppTextStyles.label.copyWith(color: c.textPrimary)),
          ),
          if (valid) ...[const Spacer(), AppIcon('field-valid', width: 13.33, height: 13.33, color: c.success)],
        ]),
        const SizedBox(height: 6),
        child,
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error!, style: AppTextStyles.caption.copyWith(color: c.error)),
        ],
      ],
    );
  }
}

/// 44 px input of the add-shop form.
class AppTextInput extends StatelessWidget {
  const AppTextInput({
    super.key,
    this.controller,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.enabled = true,
    this.hasError = false,
  });

  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    OutlineInputBorder border(Color color) => OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: color));
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        enabled: enabled,
        style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary, height: 17 / 14),
        cursorColor: c.accent,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: c.inputBg,
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13.5),
          prefixIcon: prefix == null ? null : Padding(padding: const EdgeInsets.only(left: 12, right: 8), child: prefix),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffix,
          enabledBorder: border(hasError ? c.error : c.inputBorder),
          disabledBorder: border(c.inputBorder),
          focusedBorder: border(hasError ? c.error : c.accent),
        ),
      ),
    );
  }
}
