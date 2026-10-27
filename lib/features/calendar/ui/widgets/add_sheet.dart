import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';

/// S7 Agregar: hoja inferior para elegir entre una tarea o un bloque de
/// estudio. Cierra la hoja y abre la pantalla elegida.
Future<void> showAddSheet(BuildContext context) {
  // Primero se cierra la hoja (sheetContext) y después se navega con el
  // context del calendario; si no, la pantalla nueva queda debajo de la hoja.
  void open(BuildContext sheetContext, String route) {
    Navigator.pop(sheetContext);
    Navigator.pushNamed(context, route);
  }

  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('¿Qué quieres agregar?', textAlign: TextAlign.center, style: SfTypography.h2),
        const SizedBox(height: SfSpacing.md),
        _AddOption(
          icon: Icons.check_box_outlined,
          title: 'Nueva tarea',
          subtitle: 'Una entrega, un proyecto o un parcial',
          highlighted: true,
          onTap: () => open(sheetContext, AppRoutes.newTask),
        ),
        const SizedBox(height: SfSpacing.sm),
        _AddOption(
          icon: Icons.schedule,
          title: 'Nuevo bloque de estudio',
          subtitle: 'Tiempo para avanzar en una tarea',
          onTap: () => open(sheetContext, AppRoutes.newStudyBlock),
        ),
        const SizedBox(height: SfSpacing.xs),
        SfButton(
          label: 'Cancelar',
          variant: SfButtonVariant.ghost,
          onPressed: () => Navigator.pop(sheetContext),
        ),
      ],
    ),
  );
}

/// Una opción de la hoja: ícono, título, subtítulo y flecha.
class _AddOption extends StatelessWidget {
  const _AddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  static const _iconBox = 40.0;

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Ícono con fondo violeta: la opción más usada.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.md, vertical: SfSpacing.sm),
      child: Row(
        children: [
          Container(
            width: _iconBox,
            height: _iconBox,
            decoration: BoxDecoration(
              color: highlighted ? SfColors.primary : SfColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: highlighted ? SfColors.textPrimary : SfColors.primaryLight),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SfTypography.bodyStrong),
                Text(subtitle, style: SfTypography.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: SfColors.textSecondary),
        ],
      ),
    );
  }
}
