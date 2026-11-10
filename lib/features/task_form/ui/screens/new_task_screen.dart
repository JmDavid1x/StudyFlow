import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_body.dart';

/// Nueva tarea (Figma 14). Formulario vacío con las materias reales; al
/// guardar en Supabase va a Tarea guardada (Figma 15) con la actividad.
/// Puede recibir una [Materia] para dejarla elegida. El TaskFormCubit lo
/// crea task_form_routes.dart.
class NewTaskScreen extends StatelessWidget {
  const NewTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Nueva tarea', useCloseIcon: true),
            Expanded(
              child: TaskFormBody(
                submitLabel: 'Guardar tarea',
                materiaInicial: args is Materia ? args : null,
                // Reemplaza esta pantalla: al volver desde Tarea guardada no
                // se regresa a un formulario ya guardado.
                onGuardada: (actividad) => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.taskSaved,
                  arguments: actividad,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
