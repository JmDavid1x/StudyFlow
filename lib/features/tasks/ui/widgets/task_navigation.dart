import 'package:flutter/widgets.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/navigation/app_routes.dart';

/// Abre el detalle de una actividad: el de examen (29) si es examen y el de
/// tarea (18) si no. Lo usan Inicio y Tareas.
void openTaskDetail(BuildContext context, DemoTask task) {
  Navigator.pushNamed(
    context,
    task.isExam ? AppRoutes.examDetail : AppRoutes.taskDetail,
    arguments: task,
  );
}
