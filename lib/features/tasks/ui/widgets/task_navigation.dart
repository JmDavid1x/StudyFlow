import 'package:flutter/widgets.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/navigation/app_routes.dart';

/// Abre el detalle de una actividad: el de examen (29) si es examen y el de
/// tarea (18) si no. Lo usan Inicio, Tareas y Notificaciones. Termina cuando
/// el usuario vuelve: quien la llama recarga sus datos después del await.
Future<void> openTaskDetail(BuildContext context, Actividad actividad) => Navigator.pushNamed(
  context,
  actividad.esExamen ? AppRoutes.examDetail : AppRoutes.taskDetail,
  arguments: actividad,
);
