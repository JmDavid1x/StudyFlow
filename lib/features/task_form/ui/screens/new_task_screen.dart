import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form.dart';

/// Nueva tarea (Figma 14). Formulario vacío; al guardar va a Tarea guardada
/// (Figma 15) y le pasa lo que se llenó para mostrar el resumen.
class NewTaskScreen extends StatelessWidget {
  const NewTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Nueva tarea', useCloseIcon: true),
            Expanded(
              child: TaskForm(
                submitLabel: 'Guardar tarea',
                // Reemplaza esta pantalla: al volver desde Tarea guardada no
                // se regresa a un formulario ya guardado.
                onSubmit: (data) => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.taskSaved,
                  arguments: data,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
