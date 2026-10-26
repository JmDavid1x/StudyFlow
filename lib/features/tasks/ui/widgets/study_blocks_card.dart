import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_extras.dart';

/// "Bloques de estudio · 1 de 2 hechos" con sus filas y el enlace para
/// agregar uno (Figma 18 y 29).
class StudyBlocksCard extends StatelessWidget {
  const StudyBlocksCard({super.key, required this.blocks, required this.color});

  final List<TaskBlock> blocks;

  /// Color de la materia, para el círculo de los bloques pendientes.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final done = blocks.where((block) => block.done).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          blocks.isEmpty ? 'Bloques de estudio' : 'Bloques de estudio · $done de ${blocks.length} hechos',
          style: SfTypography.label,
        ),
        const SizedBox(height: SfSpacing.xs),
        SfCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (blocks.isEmpty)
                const SfEmptyState(
                  icon: Icons.schedule_rounded,
                  title: 'Sin bloques de estudio',
                  message: 'Agrega un bloque para avanzar con tiempo y no dejarlo para el último día.',
                ),
              for (final block in blocks) ...[
                _BlockRow(block: block, color: color),
                const Divider(height: 1, color: SfColors.border),
              ],
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.newStudyBlock),
                style: TextButton.styleFrom(
                  foregroundColor: SfColors.primaryLight,
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size.fromHeight(SfSpacing.xxl),
                  padding: const EdgeInsets.symmetric(horizontal: SfSpacing.md),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  'Agregar bloque de estudio',
                  style: SfTypography.bodyStrong.copyWith(color: SfColors.primaryLight),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlockRow extends StatelessWidget {
  const _BlockRow({required this.block, required this.color});

  final TaskBlock block;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Los bloques hechos ya no se abren; los pendientes van a Figma 27.
      onTap: block.done ? null : () => Navigator.pushNamed(context, AppRoutes.studyBlock),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(SfSpacing.xxs, SfSpacing.xxs, SfSpacing.md, SfSpacing.xxs),
        child: Row(
          children: [
            SfCheckCircle(checked: block.done, color: color),
            const SizedBox(width: SfSpacing.xxs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.title,
                    style: SfTypography.bodyStrong.copyWith(
                      color: block.done ? SfColors.textSecondary : SfColors.textPrimary,
                    ),
                  ),
                  Text(block.when, style: SfTypography.caption),
                ],
              ),
            ),
            if (!block.done) const Icon(Icons.chevron_right, color: SfColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
