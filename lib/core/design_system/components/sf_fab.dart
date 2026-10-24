import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';

/// Botón flotante para agregar (tarea, bloque). Es el único elemento con
/// sombra de color: marca la acción más frecuente de la app.
class SfFab extends StatelessWidget {
  const SfFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.tooltip = 'Agregar',
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: SfColors.primary.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox.square(
        dimension: 64,
        child: FloatingActionButton(
          // Sin heroTag: varias pestañas tienen su propio botón flotante.
          heroTag: null,
          elevation: 0,
          tooltip: tooltip,
          onPressed: onPressed,
          child: Icon(icon, size: 30),
        ),
      ),
    );
  }
}
