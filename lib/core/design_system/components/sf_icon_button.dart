import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';

/// Botón redondo con ícono: atrás, cerrar, notificaciones.
class SfIconButton extends StatelessWidget {
  const SfIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.filled = false,
    this.size = 44,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Texto para lectores de pantalla: "Atrás", "Notificaciones".
  final String tooltip;

  /// Relleno violeta para la acción destacada (por ejemplo, el asistente).
  final bool filled;
  final double size;

  /// Punto rojo de "hay algo nuevo" (notificaciones sin leer).
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: filled ? SfColors.primary : SfColors.surface,
      shape: CircleBorder(
        side: filled ? BorderSide.none : const BorderSide(color: SfColors.border),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Icon(icon, size: size * 0.46, color: SfColors.textPrimary),
        ),
      ),
    );

    return Tooltip(
      message: tooltip,
      child: showDot
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                button,
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: SfColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: SfColors.background, width: 2),
                    ),
                  ),
                ),
              ],
            )
          : button,
    );
  }
}
