import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/block_completed_sheet.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/demo_agenda.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/discard_block_sheet.dart';

/// S10 Bloque pendiente. Aparece cuando ya pasó la hora del bloque y no se
/// marcó como hecho: se puede confirmar, reprogramar o descartar.
Future<void> showBlockPendingSheet(BuildContext context, AgendaItem block) {
  return showSfBottomSheet<void>(
    context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Bloque pendiente', textAlign: TextAlign.center, style: SfTypography.h2),
        const SizedBox(height: SfSpacing.xs),
        Text(
          '"${block.title}" era de ${formatTimeRange(block.start, block.end)}. ¿Alcanzaste a hacerlo?',
          textAlign: TextAlign.center,
          style: SfTypography.body.copyWith(color: SfColors.textSecondary),
        ),
        const SizedBox(height: SfSpacing.lg),
        SfButton(
          label: 'Lo hice',
          onPressed: () {
            Navigator.pop(sheetContext);
            showBlockCompletedSheet(context, block);
          },
        ),
        const SizedBox(height: SfSpacing.xs),
        SfButton(
          label: 'Reprogramar',
          variant: SfButtonVariant.secondary,
          onPressed: () {
            Navigator.pop(sheetContext);
            Navigator.pushNamed(context, AppRoutes.newStudyBlock, arguments: block);
          },
        ),
        const SizedBox(height: SfSpacing.xxs),
        SfButton(
          label: 'Descartar',
          variant: SfButtonVariant.ghost,
          onPressed: () {
            Navigator.pop(sheetContext);
            discardBlockAndGoBack(context);
          },
        ),
      ],
    ),
  );
}
