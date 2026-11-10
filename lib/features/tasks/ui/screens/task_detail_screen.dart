import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/tasks/data/tasks_repository_impl.dart';
import 'package:studyflow/features/tasks/domain/textos_actividad.dart';
import 'package:studyflow/features/tasks/domain/usecases/marcar_no_entregada.dart';
import 'package:studyflow/features/tasks/ui/bloc/task_detail_cubit.dart';
import 'package:studyflow/features/tasks/ui/widgets/confirm_sheet.dart';
import 'package:studyflow/features/tasks/ui/widgets/detail_info_card.dart';
import 'package:studyflow/features/tasks/ui/widgets/missing_activity.dart';
import 'package:studyflow/features/tasks/ui/widgets/study_blocks_card.dart';
import 'package:studyflow/features/tasks/ui/widgets/subject_pill.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_completed_sheet.dart';

/// Detalle de tarea (Figma 18) con sus hojas: S1 Tarea completada, S2
/// Eliminar tarea y S8 Tarea vencida (se abre sola si la tarea venció).
///
/// Recibe la [Actividad] como argumento de la ruta (ver openTaskDetail).
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Actividad) return const MissingActivity(title: 'Detalle de tarea');
    return BlocProvider(
      create: (_) => TaskDetailCubit(TasksRepositoryImpl(supabase), args)..cargarBloques(),
      child: const _TaskDetailView(),
    );
  }
}

class _TaskDetailView extends StatefulWidget {
  const _TaskDetailView();

  @override
  State<_TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<_TaskDetailView> {
  TaskDetailCubit get _cubit => context.read<TaskDetailCubit>();

  /// Último error ya mostrado en un SnackBar.
  int _shownAvisoId = 0;

  bool _isOverdue(Actividad actividad) => MarcarNoEntregada.puede(actividad, _cubit.ahora);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isOverdue(_cubit.state.actividad)) _askIfDelivered();
    });
  }

  void _onChange(BuildContext context, TaskDetailState state) {
    switch (state.resultado) {
      case ResultadoDetalle.completada when state.resumen != null:
        showTaskCompletedSheet(context, state.actividad, state.resumen!);
      case ResultadoDetalle.eliminada:
        Navigator.pop(context);
      default:
        break;
    }
  }

  Future<void> _edit(Actividad actividad) async {
    await Navigator.pushNamed(context, AppRoutes.editTask, arguments: actividad);
    if (mounted) await _cubit.recargar();
  }

  void _askIfDelivered() {
    final actividad = _cubit.state.actividad;
    showSfBottomSheet<void>(
      context,
      builder: (sheetContext) => ConfirmSheet(
        icon: Icons.warning_amber_rounded,
        title: '¿Entregaste "${actividad.titulo}"?',
        message: 'Venció ${fechaCorta(actividad.fechaLimite, _cubit.ahora)}. Cuéntanos para mantener tu lista al día.',
        confirm: SfButton(
          label: 'Sí, la entregué',
          icon: Icons.check_rounded,
          onPressed: () {
            Navigator.pop(sheetContext);
            _cubit.completar();
          },
        ),
        cancelLabel: 'No la entregué',
        onCancel: () {
          Navigator.pop(sheetContext);
          _cubit.marcarNoEntregada();
        },
        footnote: 'Si no la entregaste, pasa a "No entregadas" y deja de contar como pendiente.',
      ),
    );
  }

  void _confirmDelete() {
    final actividad = _cubit.state.actividad;
    showSfBottomSheet<void>(
      context,
      builder: (sheetContext) => ConfirmSheet(
        icon: Icons.delete_outline_rounded,
        title: '¿Eliminar esta tarea?',
        message: 'Se borrará "${actividad.titulo}" con sus bloques y recordatorios. No se puede deshacer.',
        confirm: SfButton(
          label: 'Eliminar tarea',
          variant: SfButtonVariant.danger,
          onPressed: () {
            Navigator.pop(sheetContext);
            _cubit.eliminar();
          },
        ),
        cancelLabel: 'Cancelar',
      ),
    );
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
        _onChange(context, state);
      },
      builder: (context, state) => _build(state),
    );
  }

  Widget _build(TaskDetailState state) {
    final actividad = state.actividad;
    final ahora = _cubit.ahora;
    final color = actividad.materiaColor ?? SfColors.primaryLight;
    final done = actividad.estado == EstadoActividad.completada;
    final notDelivered = actividad.estado == EstadoActividad.noEntregada;
    final closed = actividad.estado.estaCerrada;
    final overdue = _isOverdue(actividad);
    final gradePart = parteDeLaNota(actividad);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SfScreenHeader(
              title: 'Detalle de tarea',
              trailing: SfIconButton(icon: Icons.edit_outlined, tooltip: 'Editar', onPressed: () => _edit(actividad)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: SfSpacing.xs,
                      runSpacing: SfSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SubjectPill(name: actividad.materiaNombre ?? 'Sin materia', color: color),
                        if (done) const SfBadge(label: 'Completada', tone: SfTone.success),
                        if (notDelivered) const SfBadge(label: 'No entregada', tone: SfTone.danger),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.sm),
                    Text(actividad.titulo, style: SfTypography.h1),
                    const SizedBox(height: SfSpacing.md),
                    DetailInfoCard(
                      rows: [
                        DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Entrega',
                          value: fechaLarga(actividad.fechaLimite, ahora),
                          note: tiempoRestante(actividad, ahora),
                          noteColor: overdue ? SfColors.danger : SfColors.warning,
                        ),
                        if (actividad.canalEntrega != null)
                          DetailRow(
                            icon: Icons.send_outlined,
                            label: 'Se entrega por',
                            value: canalTexto(actividad.canalEntrega!),
                          ),
                        DetailRow(
                          icon: Icons.flag_outlined,
                          label: 'Prioridad',
                          value: _sentenceCase(actividad.prioridad.db),
                        ),
                        if (gradePart != null)
                          DetailRow(icon: Icons.percent_rounded, label: 'Parte de la nota', value: gradePart),
                        if (actividad.recordatorio)
                          const DetailRow(icon: Icons.alarm_rounded, label: 'Recordatorio', value: 'Activado'),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    StudyBlocksCard(
                      actividad: actividad,
                      blocks: state.bloques,
                      color: color,
                      loading: state.cargandoBloques,
                      onReturn: _cubit.recargar,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.md),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DeleteButton(onPressed: state.ocupado ? null : _confirmDelete),
                    const SizedBox(width: SfSpacing.sm),
                    Expanded(
                      child: SfButton(
                        label: switch (actividad.estado) {
                          EstadoActividad.completada => 'Completada',
                          EstadoActividad.noEntregada => 'No entregada',
                          _ => 'Marcar como completada',
                        },
                        icon: Icons.check_rounded,
                        // Si venció, primero se pregunta si se entregó (S8).
                        onPressed: closed || state.ocupado ? null : (overdue ? _askIfDelivered : _cubit.completar),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "alta" → "Alta".
String _sentenceCase(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

/// Botón cuadrado con la papelera, al lado de la acción principal.
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.lg);
    return Tooltip(
      message: 'Eliminar tarea',
      child: Material(
        color: SfColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Container(
            width: SfSpacing.xxl + SfSpacing.xxs,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: SfColors.border),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: SfColors.danger),
          ),
        ),
      ),
    );
  }
}
