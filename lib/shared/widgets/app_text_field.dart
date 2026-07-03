import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/input_formatters.dart';

/// Themed text field (`.field`) with an optional label above.
/// Visual styling comes from the global [InputDecorationTheme]; this wrapper
/// only standardizes layout. All form behavior is passed through untouched.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffix,
    this.onTap,
    this.focusNode,
    this.textDirection,
    this.autofocus = false,
    this.autovalidateMode,
    this.helperText,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final IconData? prefixIcon;
  final Widget? suffix;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextDirection? textDirection;
  final bool autofocus;
  final AutovalidateMode? autovalidateMode;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Numeric/phone fields: auto-convert Arabic digits to ASCII and render the
    // content left-to-right so pasted numbers don't appear reversed in RTL.
    final kt = keyboardType;
    final isNumeric = kt != null &&
        (kt.index == TextInputType.number.index ||
            kt.index == TextInputType.phone.index);
    final effectiveFormatters = <TextInputFormatter>[
      if (isNumeric) const ArabicDigitsInputFormatter(),
      ...?inputFormatters,
    ];
    final field = TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: effectiveFormatters.isEmpty ? null : effectiveFormatters,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      focusNode: focusNode,
      textDirection:
          textDirection ?? (isNumeric ? TextDirection.ltr : null),
      autofocus: autofocus,
      autovalidateMode: autovalidateMode,
      style: AppTextStyles.body.copyWith(fontSize: 15, color: colors.ink),
      decoration: InputDecoration(
        hintText: hint,
        helperText: helperText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: colors.ink3)
            : null,
        suffixIcon: suffix,
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            label!,
            style: AppTextStyles.label.copyWith(color: colors.ink2),
          ),
        ),
        field,
      ],
    );
  }
}
