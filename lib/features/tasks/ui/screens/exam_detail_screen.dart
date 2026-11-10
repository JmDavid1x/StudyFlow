import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/tasks/data/tasks_repository_impl.dart';
import 'package:studyflow/features/tasks/domain/textos_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/marcar_presentado.dart';
import 'package:studyflow/features/tasks/ui/bloc/task_detail_cubit.dart';
import 'package:studyflow/features/tasks/ui/widgets/detail_info_card.dart';
import 'package:studyflow/features/tasks/ui/widgets/missing_activity.dart';
import 'package:studyflow/features/tasks/ui/widgets/study_blocks_card.dart';
import 'package:studyflow/features/tasks/ui/widgets/subject_pill.dart';

/// Detalle de examen (Figma 29). Un examen está pendiente o presentado,
/// nunca "en progreso": por eso el estado tiene solo dos opciones.
///
/// Recibe la [Actividad] del examen como argumento de la ruta.
class ExamDetailScreen extends StatelessWidget {
  const ExamDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Actividad) return const MissingActivity(title: 'Detalle de examen');
    return BlocProvider(
      create: (_) => TaskDetailCubit(TasksRepositoryImpl(supabase), args)..cargarBloques(),
      child: const _ExamDetailView(),
    );
  }
}

class _ExamDetailView extends StatefulWidget {
  const _ExamDetailView();

  @override
  State<_ExamDetailView> createState() => _ExamDetailViewState();
}

class _ExamDetailViewState extends State<_ExamDetailView> {
  TaskDetailCubit get _cubit => context.read<TaskDetailCubit>();

  /// Último error ya mostrado en un SnackBar.
  int _shownAvisoId = 0;

  /// Abre otra pantalla con el examen y, al volver, lo recarga.
  Future<void> _openThenReload(String route) async {
    await Navigator.pushNamed(context, route, arguments: _cubit.state.actividad);
    if (mounted) await _cubit.recargar();
  }

  void _onStatus(bool presented) {
    final exam = _cubit.state.actividad;
    if (presented && MarcarPresentado.puede(exam)) {
      _cubit.marcarPresentado();
    } else if (!presented && exam.estado == EstadoActividad.presentado) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Un examen presentado ya no vuelve a pendiente.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskDetailCubit, TaskDetailState>(
      listenWhen: (previous, current) => previous.resultado != current.resultado || previous.avisoId != current.avisoId,
      listener: (context, state) {
        if (state.avisoId != _shownAvisoId) {
          _shownAvisoId = state.avisoId;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.aviso ?? '')));
        }
        if (state.resultado == ResultadoDetalle.eliminada) Navigator.pop(context);
      },
      builder: (context, state) => _build(state),
    );
  }

  Widget _build(TaskDetailState state) {
    final exam = state.actividad;
    final ahora = _cubit.ahora;
    final color = exam.materiaColor ?? SfColors.primaryLight;
    final presented = exam.estado == EstadoActividad.presentado;
    final gradePart = parteDeLaNota(exam);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SfScreenHeader(
              title: 'Detalle de examen',
              trailing: SfIconButton(
                icon: Icons.edit_outlined,
                tooltip: 'Editar',
                onPressed: () => _openThenReload(AppRoutes.editTask),
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
                      child: SubjectPill(name: exam.materiaNombre ?? 'Sin materia', color: color),
                    ),
                    const SizedBox(height: SfSpacing.sm),
                    Text(exam.titulo, style: SfTypography.h1),
                    const SizedBox(height: SfSpacing.md),
                    DetailInfoCard(
                      rows: [
                        DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Fecha',
                          value: fechaLarga(exam.fechaLimite, ahora),
                          note: tiempoRestante(exam, ahora),
                          noteColor: exam.estaVencida(ahora) ? SfColors.danger : SfColors.warning,
                        ),
                        if (exam.lugar != null && exam.lugar!.isNotEmpty)
                          DetailRow(icon: Icons.place_outlined, label: 'Lugar', value: exam.lugar!),
                        if (gradePart != null)
                          DetailRow(icon: Icons.percent_rounded, label: 'Parte de la nota', value: gradePart),
                        if (exam.recordatorio)
                          const DetailRow(icon: Icons.alarm_rounded, label: 'Recordatorio', value: 'Activado'),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    StudyBlocksCard(
                      actividad: exam,
                      blocks: state.bloques,
                      color: color,
                      loading: state.cargandoBloques,
                      onReturn: _cubit.recargar,
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    Text('Estado', style: SfTypography.label),
                    const SizedBox(height: SfSpacing.xs),
                    SfSegmented<bool>(
                      segments: const [(false, 'Pendiente'), (true, 'Presentado')],
                      selected: presented,
                      onChanged: state.ocupado ? (_) {} : _onStatus,
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
                onPressed: () => _openThenReload(AppRoutes.registerGrade),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
