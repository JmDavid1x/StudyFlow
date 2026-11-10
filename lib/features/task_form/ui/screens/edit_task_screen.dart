import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_body.dart';

/// Editar tarea (Figma 19). Es el mismo formulario de Nueva tarea con los
/// datos de la [Actividad] que llega como argumento (desde el detalle de
/// Alejandro). Al guardar vuelve atrás y devuelve la actividad actualizada.
class EditTaskScreen extends StatelessWidget {
  const EditTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Editar tarea', useCloseIcon: true),
            Expanded(
              child: args is Actividad
                  ? TaskFormBody(
                      submitLabel: 'Guardar cambios',
                      original: args,
                      onGuardada: (actividad) =>
                          Navigator.pop(context, actividad),
                    )
                  // Sin actividad no hay nada que editar; no se rompe.
                  : Center(
                      child: SingleChildScrollView(
                        child: SfEmptyState(
                          icon: Icons.edit_off_outlined,
                          title: 'No encontramos la tarea',
                          message: 'Vuelve e intenta abrirla de nuevo.',
                          actionLabel: 'Volver',
                          onAction: () => Navigator.pop(context),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
