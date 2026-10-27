import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';
import 'package:studyflow/features/subjects/ui/screens/setup_subjects_screen.dart';

/// Rutas de Configuración y materias (Miguel).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> subjectsRoutes = {
  AppRoutes.setupSubjects: (_) => const SetupSubjectsScreen(),
  AppRoutes.newSubject: (_) => const PlaceholderScreen(figma: '09', title: 'Nueva materia', owner: Team.p2),
  AppRoutes.setupReminders: (_) => const PlaceholderScreen(figma: '10', title: 'Activar recordatorios', owner: Team.p2),
  AppRoutes.subjectDetail: (_) => const PlaceholderScreen(figma: '22', title: 'Materia', owner: Team.p2),
  AppRoutes.registerGrade: (_) => const PlaceholderScreen(figma: '23', title: 'Registrar nota', owner: Team.p2),
};
