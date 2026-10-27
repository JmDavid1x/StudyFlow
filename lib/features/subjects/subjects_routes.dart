import 'package:flutter/widgets.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/subjects/ui/screens/new_subject_screen.dart';
import 'package:studyflow/features/subjects/ui/screens/register_grade_screen.dart';
import 'package:studyflow/features/subjects/ui/screens/setup_reminders_screen.dart';
import 'package:studyflow/features/subjects/ui/screens/setup_subjects_screen.dart';
import 'package:studyflow/features/subjects/ui/screens/subject_detail_screen.dart';

/// Rutas de Configuración y materias (Miguel).
///
/// Cuando termines una pantalla, cambia su PlaceholderScreen por tu pantalla.
/// Solo tú editas este archivo, así no hay conflictos con el resto del equipo.
final Map<String, WidgetBuilder> subjectsRoutes = {
  AppRoutes.setupSubjects: (_) => const SetupSubjectsScreen(),
  AppRoutes.newSubject: (_) => const NewSubjectScreen(),
  AppRoutes.setupReminders: (_) => const SetupRemindersScreen(),
  AppRoutes.subjectDetail: (_) => const SubjectDetailScreen(),
  AppRoutes.registerGrade: (_) => const RegisterGradeScreen(),
};
