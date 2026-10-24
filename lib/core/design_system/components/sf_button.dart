import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_radius.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

enum SfButtonVariant {
  /// La acción principal de la pantalla. Solo una por pantalla.
  primary,

  /// Acción alternativa, con borde.
  secondary,

  /// Acción de bajo peso, solo texto: "Seguir con el plan gratis".
  ghost,

  /// Acción destructiva: "Eliminar tarea".
  danger,
}

/// Botón de StudyFlow. Ocupa todo el ancho por defecto.
class SfButton extends StatelessWidget {
  const SfButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SfButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;

  /// Si es null, el botón se ve deshabilitado.
  final VoidCallback? onPressed;
  final SfButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    var background = SfColors.primary;
    var foreground = SfColors.textPrimary;
    Color? borderColor;
    switch (variant) {
      case SfButtonVariant.primary:
        background = SfColors.primary;
        foreground = SfColors.textPrimary;
      case SfButtonVariant.secondary:
        background = SfColors.surface;
        foreground = SfColors.textPrimary;
        borderColor = SfColors.border;
      case SfButtonVariant.ghost:
        background = Colors.transparent;
        foreground = SfColors.primaryLight;
      case SfButtonVariant.danger:
        background = SfColors.danger.withValues(alpha: 0.14);
        foreground = SfColors.danger;
    }

    final enabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(SfRadius.lg);
    final height = variant == SfButtonVariant.ghost ? 44.0 : 53.0;

    final content = isLoading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: SfTypography.button.copyWith(color: foreground),
                ),
              ),
            ],
          );

    final button = Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: enabled ? onPressed : null,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: borderColor == null
                ? null
                : BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: borderColor),
                  ),
            child: content,
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
