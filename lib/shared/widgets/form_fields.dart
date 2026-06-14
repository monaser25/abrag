import 'package:flutter/material.dart';

import '../../core/theme/abrag_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import 'tappable.dart';

/// Prototype `Field` label: small dim label rendered above the field box.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(color: context.colors.ink2),
      ),
    );
  }
}

/// Themed dropdown with the prototype label-above-fieldbox layout.
/// Pure presentation wrapper around [DropdownButtonFormField] — selection
/// state, items, callbacks, and validation are passed through untouched.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    this.label,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.helperText,
    this.fieldKey,
  });

  final String? label;
  final List<DropdownMenuItem<T>> items;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final String? helperText;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final field = DropdownButtonFormField<T>(
      key: fieldKey,
      isExpanded: true,
      initialValue: initialValue,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: AppTextStyles.body.copyWith(fontSize: 15, color: colors.ink),
      icon: Icon(Icons.expand_more, size: 20, color: colors.ink3),
      dropdownColor: colors.surface2,
      decoration: InputDecoration(
        helperText: helperText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: colors.ink3)
            : null,
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_FieldLabel(label!), field],
    );
  }
}

/// Prototype-style tappable date/time field: label above, fieldbox surface,
/// leading calendar icon. Visual replacement for bordered date `ListTile`s —
/// [onTap] keeps whatever picker logic the caller already has.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    this.label,
    required this.value,
    this.placeholder,
    this.onTap,
    this.icon = Icons.calendar_today,
  });

  final String? label;
  final String? value;
  final String? placeholder;
  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasValue = value != null && value!.isNotEmpty;
    final tile = Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: colors.surface3,
          borderRadius: AppRadius.rSm,
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.ink3),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasValue ? value! : (placeholder ?? ''),
                style: AppTextStyles.body.copyWith(
                  fontSize: 15,
                  color: hasValue ? colors.ink : colors.ink3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.expand_more, size: 18, color: colors.ink3),
          ],
        ),
      ),
    );

    if (label == null) return tile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_FieldLabel(label!), tile],
    );
  }
}

/// Card-style switch row replacing bare [SwitchListTile]s in forms:
/// fieldbox surface, title/subtitle, themed switch. Toggle state and
/// callback pass through untouched.
class AppSwitchRow extends StatelessWidget {
  const AppSwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.tint,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onChanged != null;
    return Tappable(
      onTap: enabled ? () => onChanged!(!value) : null,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: AppRadius.rSm,
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19, color: tint ?? colors.ink2),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title.copyWith(
                      color: enabled ? colors.ink : colors.ink3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
