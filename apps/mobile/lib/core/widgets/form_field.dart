import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'adaptive.dart';
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
        Row(
          children: [
            // The label takes the row, so the check always sits at the right edge, in line with the input.
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  children: [
                    if (required)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: c.error, fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
                style: AppTextStyles.label.copyWith(color: c.textPrimary),
              ),
            ),
            if (valid) AppIcon('field-valid', width: 13.33, height: 13.33, color: c.success),
          ],
        ),
        const SizedBox(height: 6),
        child,
        if (error != null) ...[const SizedBox(height: 4), Text(error!, style: AppTextStyles.caption.copyWith(color: c.error))],
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
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.bare = false,
    this.textStyle,
    this.inputFormatters,
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
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;

  /// No fill, border or padding: for a field inside its own box (the audit comment).
  final bool bare;
  final TextStyle? textStyle;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = textStyle ?? AppTextStyles.bodyMedium.copyWith(color: c.textPrimary, height: 17 / 14);
    final hintStyle = style.copyWith(color: c.textSecondary);
    final multiline = maxLines != 1;
    if (context.isCupertino) {
      return SizedBox(
        height: multiline || bare ? null : 44,
        child: CupertinoTextField(
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          enabled: enabled,
          style: style,
          cursorColor: c.accent,
          placeholder: hint,
          placeholderStyle: hintStyle,
          padding: bare ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 12, vertical: multiline ? 10 : 0),
          prefix: prefix == null ? null : Padding(padding: const EdgeInsets.only(left: 12), child: prefix),
          suffix: suffix,
          decoration: bare
              ? null
              : BoxDecoration(
                  color: c.inputBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: hasError ? c.error : c.inputBorder),
                ),
        ),
      );
    }
    return SizedBox(
      height: multiline || bare ? null : 44,
      child: TextField(
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        autofocus: autofocus,
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        enabled: enabled,
        style: style,
        // Borders, fill and padding come from the theme's InputDecorationTheme.
        decoration: bare
            ? InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                hintText: hint,
                hintStyle: hintStyle,
              )
            : InputDecoration(
                hintText: hint,
                hintStyle: hintStyle,
                counterText: '',
                prefixIcon: prefix == null ? null : Padding(padding: const EdgeInsets.only(left: 12, right: 8), child: prefix),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: suffix,
                enabledBorder: hasError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: c.error),
                      )
                    : null,
                focusedBorder: hasError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: c.error),
                      )
                    : null,
              ),
      ),
    );
  }
}

/// A labelled text field of a [Form] (Flutter's FormField): validates once the user has interacted with it
/// (`AutovalidateMode.onUserInteraction`) and on [FormState.validate], showing the error under the input with a red
/// border, and the green check (`252:26607`) when a filled value is valid. It follows its [controller], so text set
/// in code (a clear button, a loaded record) is validated too.
class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.required = false,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.dependsOn = const [],
  });

  final String label;
  final TextEditingController controller;

  /// Other fields this one's rule reads (the audit plan reads the visit plan): when they change, a field the user
  /// has touched validates again.
  final List<Listenable> dependsOn;

  /// The message for a wrong value, or null.
  final String? Function(String value)? validator;
  final bool required;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  final _field = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
    for (final d in widget.dependsOn) {
      d.addListener(_recheck);
    }
  }

  void _recheck() {
    final state = _field.currentState;
    if (state != null && state.hasInteractedByUser) state.validate();
  }

  @override
  void didUpdateWidget(AppTextFormField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    for (final d in widget.dependsOn) {
      d.removeListener(_recheck);
    }
    super.dispose();
  }

  // Typing and text set in code both reach the form field.
  void _sync() {
    final state = _field.currentState;
    if (state != null && state.value != widget.controller.text) state.didChange(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return FormField<String>(
      key: _field,
      initialValue: w.controller.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) => w.validator?.call(v ?? ''),
      builder: (state) {
        final text = state.value ?? '';
        return AppFormField(
          label: w.label,
          required: w.required,
          error: state.errorText,
          valid: text.trim().isNotEmpty && w.validator?.call(text) == null,
          child: AppTextInput(
            controller: w.controller,
            hint: w.hint,
            keyboardType: w.keyboardType,
            textInputAction: w.textInputAction,
            inputFormatters: w.inputFormatters,
            prefix: w.prefix,
            suffix: w.suffix,
            minLines: w.minLines,
            maxLines: w.maxLines,
            maxLength: w.maxLength,
            hasError: state.hasError,
            onChanged: w.onChanged,
          ),
        );
      },
    );
  }
}
