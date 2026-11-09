import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/tasks/domain/textos_actividad.dart';

/// "Bloques de estudio · 1 de 2 hechos" con sus filas y el enlace para
/// agregar uno (Figma 18 y 29).
class StudyBlocksCard extends StatelessWidget {
  const StudyBlocksCard({
    super.key,
    required this.actividad,
    required this.blocks,
    required this.color,
    this.loading = false,
    this.onReturn,
  });

  /// La actividad que preparan los bloques (va como argumento a Nuevo bloque).
  final Actividad actividad;
  final List<BloqueEstudio> blocks;

  /// Color de la materia, para el círculo de los bloques pendientes.
  final Color color;
  final bool loading;

  /// Se llama al volver de Bloque de estudio o Nuevo bloque, para recargar.
  final VoidCallback? onReturn;

  Future<void> _open(BuildContext context, String route, Object arguments) async {
    await Navigator.pushNamed(context, route, arguments: arguments);
    onReturn?.call();
  }

  @override
  Widget build(BuildContext context) {
    final done = blocks.where((block) => block.estado == EstadoBloque.completado).length;
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
              if (loading)
                const SfLoadingState(message: 'Cargando bloques…')
              else if (blocks.isEmpty)
                const SfEmptyState(
                  icon: Icons.schedule_rounded,
                  title: 'Sin bloques de estudio',
                  message: 'Agrega un bloque para avanzar con tiempo y no dejarlo para el último día.',
                ),
              for (final block in blocks) ...[
                _BlockRow(
                  title: tituloBloque(actividad),
                  when: rangoBloque(block.inicio, block.fin),
                  done: block.estado == EstadoBloque.completado,
                  color: color,
                  onTap: () => _open(context, AppRoutes.studyBlock, block),
                ),
                const Divider(height: 1, color: SfColors.border),
              ],
              TextButton.icon(
                onPressed: () => _open(context, AppRoutes.newStudyBlock, actividad),
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
  const _BlockRow({required this.title, required this.when, required this.done, required this.color, this.onTap});

  final String title;

  /// "Mar 22 · 10:00 a. m. – 12:00 p. m."
  final String when;
  final bool done;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Los bloques hechos ya no se abren; los pendientes van a Figma 27.
      onTap: done ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(SfSpacing.xxs, SfSpacing.xxs, SfSpacing.md, SfSpacing.xxs),
        child: Row(
          children: [
            SfCheckCircle(checked: done, color: color),
            const SizedBox(width: SfSpacing.xxs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SfTypography.bodyStrong.copyWith(
                      color: done ? SfColors.textSecondary : SfColors.textPrimary,
                    ),
                  ),
                  Text(when, style: SfTypography.caption),
                ],
              ),
            ),
            if (!done) const Icon(Icons.chevron_right, color: SfColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
