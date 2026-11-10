import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/calendar/ui/widgets/formato.dart';

/// S10 Bloque pendiente. Aparece cuando ya pasó la hora del bloque y no se
/// marcó como hecho: se puede confirmar, reprogramar o descartar. Las tres
/// acciones las hace la pantalla que abre la hoja.
Future<void> showBlockPendingSheet(
  BuildContext context,
  BloqueEstudio bloque, {
  required VoidCallback alHacerlo,
  required VoidCallback alReprogramar,
  required VoidCallback alDescartar,
}) {
  final titulo = bloque.actividadTitulo ?? 'Tu bloque de estudio';
  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) {
      void cerrarY(VoidCallback accion) {
        Navigator.pop(sheetContext);
        accion();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bloque pendiente',
            textAlign: TextAlign.center,
            style: SfTypography.h2,
          ),
          const SizedBox(height: SfSpacing.xs),
          Text(
            '"$titulo" era de ${rangoHoras(bloque.inicio, bloque.fin)}. '
            '¿Alcanzaste a hacerlo?',
            textAlign: TextAlign.center,
            style: SfTypography.body.copyWith(color: SfColors.textSecondary),
          ),
          const SizedBox(height: SfSpacing.lg),
          SfButton(label: 'Lo hice', onPressed: () => cerrarY(alHacerlo)),
          const SizedBox(height: SfSpacing.xs),
          SfButton(
            label: 'Reprogramar',
            variant: SfButtonVariant.secondary,
            onPressed: () => cerrarY(alReprogramar),
          ),
          const SizedBox(height: SfSpacing.xxs),
          SfButton(
            label: 'Descartar',
            variant: SfButtonVariant.ghost,
            onPressed: () => cerrarY(alDescartar),
          ),
        ],
      );
    },
  );
}
