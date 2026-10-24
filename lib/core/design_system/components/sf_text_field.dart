import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_radius.dart';
import 'package:studyflow/core/design_system/tokens/sf_spacing.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

/// Campo de texto con etiqueta arriba. Con [isPassword] trae el botón de
/// mostrar u ocultar la contraseña.
///
/// Solo para texto libre (nombres, correo, contraseña, notas). Fechas, horas,
/// materias y porcentajes se eligen con selectores, nunca con el teclado.
class SfTextField extends StatefulWidget {
  const SfTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.maxLines = 1,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final int maxLines;

  @override
  State<SfTextField> createState() => _SfTextFieldState();
}

class _SfTextFieldState extends State<SfTextField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      style: SfTypography.body,
      cursorColor: SfColors.primaryLight,
      decoration: InputDecoration(
        filled: true,
        fillColor: SfColors.surface,
        hintText: widget.hint,
        hintStyle: SfTypography.body.copyWith(color: SfColors.textDisabled),
        errorText: widget.errorText,
        errorStyle: SfTypography.caption.copyWith(color: SfColors.danger),
        prefixIconColor: SfColors.textSecondary,
        suffixIconColor: SfColors.textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _border(SfColors.border),
        enabledBorder: _border(SfColors.border),
        focusedBorder: _border(SfColors.primaryLight, 1.5),
        errorBorder: _border(SfColors.danger),
        focusedErrorBorder: _border(SfColors.danger, 1.5),
        prefixIcon: widget.icon == null ? null : Icon(widget.icon, size: 20),
        suffixIcon: widget.isPassword
            ? IconButton(
                tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                ),
              )
            : null,
      ),
    );

    if (widget.label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label!, style: SfTypography.label),
        const SizedBox(height: SfSpacing.xs - 2),
        field,
      ],
    );
  }

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(SfRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
