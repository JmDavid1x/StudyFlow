import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/subjects/ui/widgets/dashed_add_button.dart';
import 'package:studyflow/features/subjects/ui/widgets/semester_average_card.dart';
import 'package:studyflow/features/subjects/ui/widgets/subject_progress_card.dart';
import 'package:studyflow/features/subjects/ui/widgets/subjects_prototype_data.dart';

/// Pestaña Materias (Figma 21).
///
/// Resumen del semestre y una tarjeta por materia con su nota actual y su
/// meta. No lleva barra inferior: la pone MainShell.
class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  void _addSubject(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.newSubject);
  }

  @override
  Widget build(BuildContext context) {
    const subjects = prototypeSubjects;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SfLargeTitle(title: 'Materias'),
            Expanded(
              child: subjects.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: SfEmptyState(
                          icon: Icons.menu_book_outlined,
                          title: 'Aún no tienes materias',
                          message: 'Agrega tu primera materia para calcular tu nota '
                              'y organizar tu semana.',
                          actionLabel: 'Agregar materia',
                          onAction: () => _addSubject(context),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        SfSpacing.screen,
                        SfSpacing.xs,
                        SfSpacing.screen,
                        SfSpacing.lg,
                      ),
                      children: [
                        const SemesterAverageCard(subjects: subjects),
                        const SizedBox(height: SfSpacing.sm),
                        for (final subject in subjects) ...[
                          SubjectProgressCard(
                            subject: subject,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.subjectDetail,
                              arguments: subject,
                            ),
                          ),
                          const SizedBox(height: SfSpacing.sm),
                        ],
                        DashedAddButton(
                          label: 'Agregar materia',
                          onPressed: () => _addSubject(context),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
