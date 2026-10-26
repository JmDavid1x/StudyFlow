import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/demo_agenda.dart';

/// Hoja para confirmar que se descarta un bloque. Si se confirma, vuelve a
/// la pantalla anterior y avisa con "Bloque descartado".
Future<void> showDiscardBlockSheet(BuildContext context, AgendaItem block) {
  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('¿Descartar este bloque?', textAlign: TextAlign.center, style: SfTypography.h2),
        const SizedBox(height: SfSpacing.xs),
        Text(
          block.title,
          textAlign: TextAlign.center,
          style: SfTypography.bodyStrong,
        ),
        Text(
          '${sfFormatDate(block.day)} · ${formatTimeRange(block.start, block.end)}',
          textAlign: TextAlign.center,
          style: SfTypography.caption,
        ),
        const SizedBox(height: SfSpacing.sm),
        Text(
          'La tarea no se borra, solo este tiempo reservado.',
          textAlign: TextAlign.center,
          style: SfTypography.body.copyWith(color: SfColors.textSecondary),
        ),
        const SizedBox(height: SfSpacing.lg),
        SfButton(
          label: 'Descartar bloque',
          variant: SfButtonVariant.danger,
          onPressed: () {
            Navigator.pop(sheetContext);
            discardBlockAndGoBack(context);
          },
        ),
        const SizedBox(height: SfSpacing.xxs),
        SfButton(
          label: 'Cancelar',
          variant: SfButtonVariant.ghost,
          onPressed: () => Navigator.pop(sheetContext),
        ),
      ],
    ),
  );
}

/// Sale de la pantalla del bloque y muestra el aviso "Bloque descartado".
/// El ScaffoldMessenger se toma antes del pop: después, [context] ya no
/// está en pantalla y el aviso debe salir en la pantalla anterior.
void discardBlockAndGoBack(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  Navigator.pop(context);
  messenger.showSnackBar(const SnackBar(content: Text('Bloque descartado')));
}
