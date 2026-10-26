import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/tasks/ui/widgets/detail_info_card.dart';
import 'package:studyflow/features/tasks/ui/widgets/study_blocks_card.dart';
import 'package:studyflow/features/tasks/ui/widgets/subject_pill.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_extras.dart';

/// Detalle de examen (Figma 29). Un examen está pendiente o presentado,
/// nunca "en progreso": por eso el estado tiene solo dos opciones.
///
/// Recibe el examen como argumento de la ruta (un DemoTask). Sin argumento
/// muestra el examen del prototipo.
class ExamDetailScreen extends StatefulWidget {
  const ExamDetailScreen({super.key});

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  /// Solo interfaz: en el Sprint 2 el estado se guarda en Supabase.
  bool? _presented;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final exam = args is DemoTask ? args : TaskExtras.prototypeExam;
    final details = TaskExtras.of(exam);
    final presented = _presented ?? exam.done;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SfScreenHeader(
              title: 'Detalle de examen',
              trailing: SfIconButton(
                icon: Icons.edit_outlined,
                tooltip: 'Editar',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.editTask, arguments: exam),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SubjectPill(name: exam.subject, color: exam.color),
                    ),
                    const SizedBox(height: SfSpacing.sm),
                    Text(exam.title, style: SfTypography.h1),
                    const SizedBox(height: SfSpacing.md),
                    DetailInfoCard(
                      rows: [
                        DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Fecha',
                          value: details.dueLabel ?? sentenceCase(exam.due),
                          note: presented ? null : details.timeLeft,
                        ),
                        if (details.place != null)
                          DetailRow(icon: Icons.place_outlined, label: 'Lugar', value: details.place!),
                        if (details.gradePart != null)
                          DetailRow(icon: Icons.percent_rounded, label: 'Parte de la nota', value: details.gradePart!),
                        if (details.reminder != null)
                          DetailRow(icon: Icons.alarm_rounded, label: 'Recordatorio', value: details.reminder!),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    StudyBlocksCard(blocks: details.blocks, color: exam.color),
                    const SizedBox(height: SfSpacing.lg),
                    Text('Estado', style: SfTypography.label),
                    const SizedBox(height: SfSpacing.xs),
                    SfSegmented<bool>(
                      segments: const [(false, 'Pendiente'), (true, 'Presentado')],
                      selected: presented,
                      onChanged: (value) => setState(() => _presented = value),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.md),
              child: SfButton(
                label: 'Registrar nota',
                icon: Icons.star_outline_rounded,
                // Ya presentado, registrar la nota pasa a ser lo principal.
                variant: presented ? SfButtonVariant.primary : SfButtonVariant.secondary,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.registerGrade),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
