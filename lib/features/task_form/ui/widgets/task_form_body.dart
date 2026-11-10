import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/task_form/ui/bloc/task_form_cubit.dart';
import 'package:studyflow/features/task_form/ui/bloc/task_form_state.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_data.dart';

/// Cuerpo de Nueva tarea (14) y Editar tarea (19) conectado al
/// [TaskFormCubit]: muestra la carga, el error o el estado vacío, y cuando
/// hay materias, el formulario. Avisa con [onGuardada] cuando se guardó.
class TaskFormBody extends StatelessWidget {
  const TaskFormBody({
    super.key,
    required this.submitLabel,
    required this.onGuardada,
    this.original,
    this.materiaInicial,
  });

  final String submitLabel;
  final ValueChanged<Actividad> onGuardada;

  /// La actividad que se edita (Figma 19); nula en Nueva tarea.
  final Actividad? original;

  /// Materia que llega preseleccionada (por ejemplo, desde una materia).
  final Materia? materiaInicial;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskFormCubit, TaskFormState>(
      listenWhen: (antes, ahora) =>
          antes.guardada != ahora.guardada ||
          antes.errorGuardar != ahora.errorGuardar,
      listener: (context, state) {
        final guardada = state.guardada;
        if (guardada != null) {
          onGuardada(guardada);
        } else if (state.errorGuardar != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorGuardar!)));
        }
      },
      // El formulario no se reconstruye al guardar: solo cambia el botón.
      buildWhen: (antes, ahora) =>
          antes.status != ahora.status || antes.guardando != ahora.guardando,
      builder: (context, state) => switch (state.status) {
        TaskFormStatus.cargando => const SfLoadingState(
          message: 'Cargando tus materias...',
        ),
        TaskFormStatus.error => Center(
          child: SingleChildScrollView(
            child: SfErrorState(
              message: state.errorCarga ?? 'No pudimos cargar tus materias.',
              onRetry: () => context.read<TaskFormCubit>().cargar(),
            ),
          ),
        ),
        TaskFormStatus.listo when state.materias.isEmpty => Center(
          child: SingleChildScrollView(
            child: SfEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Aún no tienes materias',
              message:
                  'Agrégalas en la pestaña Materias para poder crear tareas.',
              actionLabel: 'Ir a Materias',
              onAction: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.main,
                (_) => false,
                arguments: AppTabs.subjects,
              ),
            ),
          ),
        ),
        TaskFormStatus.listo => TaskForm(
          submitLabel: submitLabel,
          materias: state.materias,
          asignados: state.asignados,
          editingId: original?.id,
          saving: state.guardando,
          initial: _initial(state.materias),
          onSubmit: (datos) =>
              context.read<TaskFormCubit>().guardar(datos, original: original),
        ),
      },
    );
  }

  TaskFormData _initial(List<Materia> materias) {
    if (original != null) {
      return TaskFormData.fromActividad(original!, materias);
    }
    final materia = materias
        .where((m) => m.id == materiaInicial?.id)
        .firstOrNull;
    return TaskFormData(materia: materia);
  }
}
