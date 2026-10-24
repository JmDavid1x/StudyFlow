import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/study_blocks/ui/screens/new_study_block_screen.dart';
import 'package:studyflow/features/study_blocks/ui/screens/study_block_screen.dart';

/// Rutas de Bloques de estudio (Camilo).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> studyBlocksRoutes = {
  AppRoutes.studyBlock: (_) => const StudyBlockScreen(),
  AppRoutes.newStudyBlock: (_) => const NewStudyBlockScreen(),
};
