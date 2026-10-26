import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Contenido de una hoja que pide una decisión: S2 Eliminar tarea y S8 Tarea
/// vencida. Se abre con showSfBottomSheet. Es como SfResultSheet, pero el
/// botón de confirmar puede ser `danger`.
class ConfirmSheet extends StatelessWidget {
  const ConfirmSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirm,
    required this.cancelLabel,
    this.onCancel,
    this.tone = SfTone.danger,
    this.footnote,
  });

  final IconData icon;
  final String title;
  final String message;

  /// El botón que confirma: un SfButton primary o danger.
  final Widget confirm;
  final String cancelLabel;

  /// Por defecto cierra la hoja.
  final VoidCallback? onCancel;
  final SfTone tone;

  /// Texto pequeño al final: qué pasa si se elige cancelar.
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final color = tone.color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: SfSpacing.xxl + SfSpacing.md,
            height: SfSpacing.xxl + SfSpacing.md,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(icon, size: SfSpacing.xl, color: color),
          ),
        ),
        const SizedBox(height: SfSpacing.sm),
        Text(title, textAlign: TextAlign.center, style: SfTypography.h1),
        const SizedBox(height: SfSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: SfTypography.body.copyWith(color: SfColors.textSecondary),
        ),
        const SizedBox(height: SfSpacing.lg),
        confirm,
        const SizedBox(height: SfSpacing.sm),
        SfButton(
          label: cancelLabel,
          variant: SfButtonVariant.secondary,
          onPressed: onCancel ?? () => Navigator.pop(context),
        ),
        if (footnote != null) ...[
          const SizedBox(height: SfSpacing.sm),
          Text(footnote!, textAlign: TextAlign.center, style: SfTypography.caption),
        ],
      ],
    );
  }
}
