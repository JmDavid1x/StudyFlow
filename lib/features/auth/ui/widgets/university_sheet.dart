import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Universidades de Cali que se ofrecen en el registro. En el Sprint 2 salen
/// de la tabla universidades de Supabase.
const universities = <String>[
  'Universidad Icesi',
  'Pontificia Universidad Javeriana Cali',
  'Universidad del Valle',
  'Universidad Autónoma de Occidente',
  'Universidad de San Buenaventura Cali',
];

/// Hoja para elegir la universidad (reemplaza al desplegable del prototipo).
/// Devuelve la elegida, o null si se cierra sin elegir.
Future<String?> showUniversitySheet(BuildContext context, {String? selected}) {
  return showSfBottomSheet<String>(
    context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Elige tu universidad', textAlign: TextAlign.center, style: SfTypography.h2),
        const SizedBox(height: SfSpacing.md),
        SfOptionCards<String>(
          columns: 1,
          selected: selected,
          onChanged: (value) => Navigator.pop(sheetContext, value),
          options: [
            for (final name in universities)
              SfOption(value: name, label: name, icon: Icons.school_outlined),
          ],
        ),
      ],
    ),
  );
}
