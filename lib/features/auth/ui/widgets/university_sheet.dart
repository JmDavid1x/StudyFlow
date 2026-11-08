import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';

/// Hoja para elegir la universidad (reemplaza al desplegable del prototipo).
/// La lista sale de la tabla `universidades` de Supabase. Devuelve la
/// elegida, o null si se cierra sin elegir.
Future<Universidad?> showUniversitySheet(
  BuildContext context, {
  required List<Universidad> universities,
  Universidad? selected,
}) {
  return showSfBottomSheet<Universidad>(
    context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Elige tu universidad', textAlign: TextAlign.center, style: SfTypography.h2),
        const SizedBox(height: SfSpacing.md),
        SfOptionCards<Universidad>(
          columns: 1,
          selected: selected,
          onChanged: (value) => Navigator.pop(sheetContext, value),
          options: [
            for (final university in universities)
              SfOption(value: university, label: university.nombre, icon: Icons.school_outlined),
          ],
        ),
      ],
    ),
  );
}
