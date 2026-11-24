import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/task_form/ui/bloc/task_form_cubit.dart';
import 'package:studyflow/features/task_form/ui/screens/edit_task_screen.dart';
import 'package:studyflow/features/task_form/ui/screens/new_task_screen.dart';
import 'package:studyflow/features/task_form/ui/screens/task_saved_screen.dart';

/// Rutas de Formularios de tarea (Camilo).
///
/// Nueva tarea y Editar tarea reciben su propio TaskFormCubit, que sale de
/// GetIt (`sl<TaskFormCubit>()`, registrado en task_form_di.dart) y ya empieza
/// a cargar las materias reales.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> taskFormRoutes = {
  AppRoutes.newTask: (_) => _conCubit(const NewTaskScreen()),
  AppRoutes.taskSaved: (_) => const TaskSavedScreen(),
  AppRoutes.editTask: (_) => _conCubit(const EditTaskScreen()),
};

Widget _conCubit(Widget pantalla) =>
    BlocProvider(create: (_) => sl<TaskFormCubit>()..cargar(), child: pantalla);
