import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_data.dart';

/// Editar tarea (Figma 19). Es el mismo formulario de Nueva tarea con los
/// datos cargados. Recibe un [TaskFormData] o un [DemoTask] como argumento;
/// sin argumento carga la tarea del prototipo.
class EditTaskScreen extends StatelessWidget {
  const EditTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final initial = switch (args) {
      TaskFormData data => data,
      DemoTask task => TaskFormData.fromDemoTask(task),
      _ => prototypeTask,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Editar tarea', useCloseIcon: true),
            Expanded(
              child: TaskForm(
                initial: initial,
                submitLabel: 'Guardar cambios',
                // Vuelve al detalle de la tarea y le entrega los cambios.
                onSubmit: (data) => Navigator.pop(context, data),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
