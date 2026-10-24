import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/block_completed_sheet.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/block_pending_sheet.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/demo_agenda.dart';

/// Bloque de estudio (Figma 27). Muestra qué tarea prepara el bloque, cuándo
/// es, cuánto dura, quién lo creó y el aviso. Recibe el bloque como argumento
/// de la ruta; sin argumento muestra el primero de la agenda de ejemplo.
class StudyBlockScreen extends StatelessWidget {
  const StudyBlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final block = args is AgendaItem && args.kind == AgendaKind.studyBlock ? args : DemoAgenda.firstBlock;
    final task = block.task!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Bloque de estudio'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SfBadge(
                      label: block.byAssistant ? 'Creado por el asistente' : 'Creado por ti',
                      tone: SfTone.info,
                    ),
                    const SizedBox(height: SfSpacing.xs),
                    Text(block.title, style: SfTypography.h1),
                    const SizedBox(height: SfSpacing.md),
                    SfCard(
                      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.md),
                      child: Column(
                        children: [
                          _InfoRow(icon: Icons.calendar_today_outlined, label: 'Día', value: sfFormatDate(block.day)),
                          _InfoRow(icon: Icons.schedule, label: 'Hora', value: formatTimeRange(block.start, block.end)),
                          _InfoRow(
                            icon: Icons.timelapse,
                            label: 'Duración',
                            value: formatDuration(block.durationMinutes),
                          ),
                          _InfoRow(
                            icon: Icons.alarm,
                            label: 'Aviso',
                            value: block.reminderMinutes == 0 ? 'Sin aviso' : '${block.reminderMinutes} min antes',
                          ),
                          _InfoRow(
                            icon: Icons.flag_outlined,
                            label: 'Estado',
                            value: block.done ? 'Completado' : 'Pendiente',
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SfSpacing.md),
                    Text('Tarea vinculada', style: SfTypography.label),
                    const SizedBox(height: SfSpacing.xs - 2),
                    SfCard(
                      onTap: () => Navigator.pushNamed(
                        context,
                        task.isExam ? AppRoutes.examDetail : AppRoutes.taskDetail,
                        arguments: task,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: SfSpacing.xs,
                            height: SfSpacing.xs,
                            decoration: BoxDecoration(color: task.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: SfSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.title, style: SfTypography.bodyStrong),
                                Text(
                                  '${task.subject} · ${task.isExam ? 'examen' : 'entrega'} ${task.due}',
                                  style: SfTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: SfColors.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: SfSpacing.md),
                    SfCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 20, color: SfColors.textSecondary),
                          const SizedBox(width: SfSpacing.sm),
                          Expanded(
                            child: Text(
                              'Completar este bloque no completa la tarea. Cuando marques la tarea '
                              'como completada, quitamos del calendario los bloques que te queden.',
                              style: SfTypography.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SfSpacing.sm),
                    // Sprint 1: S10 aparece sola cuando pasa la hora del bloque.
                    // Mientras no hay hora real, se abre desde aquí para mostrarla.
                    Center(
                      child: SfButton(
                        label: 'Ver aviso de bloque pendiente',
                        variant: SfButtonVariant.ghost,
                        expand: false,
                        onPressed: () => showBlockPendingSheet(context, block),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.md),
              child: Column(
                children: [
                  SfButton(
                    label: 'Completar bloque',
                    icon: Icons.check,
                    onPressed: () => showBlockCompletedSheet(context, block),
                  ),
                  const SizedBox(height: SfSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: SfButton(
                          label: 'Reprogramar',
                          variant: SfButtonVariant.secondary,
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.newStudyBlock, arguments: block),
                        ),
                      ),
                      const SizedBox(width: SfSpacing.xs),
                      Expanded(
                        child: SfButton(
                          label: 'Descartar',
                          variant: SfButtonVariant.ghost,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de dato del bloque: ícono, nombre y valor a la derecha.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SfSpacing.sm),
      decoration: BoxDecoration(
        border: showDivider ? const Border(bottom: BorderSide(color: SfColors.border)) : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: SfColors.primaryLight),
          const SizedBox(width: SfSpacing.sm),
          Text(label, style: SfTypography.body.copyWith(color: SfColors.textSecondary)),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Text(value, textAlign: TextAlign.end, style: SfTypography.bodyStrong),
          ),
        ],
      ),
    );
  }
}
