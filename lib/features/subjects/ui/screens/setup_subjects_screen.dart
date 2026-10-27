import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/subjects/ui/widgets/dashed_add_button.dart';
import 'package:studyflow/features/subjects/ui/widgets/subject_setup_tile.dart';
import 'package:studyflow/features/subjects/ui/widgets/subjects_prototype_data.dart';

/// Tus materias, paso 1 de la configuración inicial (Figma 08).
///
/// Lista las materias agregadas y deja agregar otra. "Continuar" lleva al
/// paso 2: activar recordatorios.
class SetupSubjectsScreen extends StatelessWidget {
  const SetupSubjectsScreen({super.key, this.subjects = prototypeSubjects});

  final List<PrototypeSubject> subjects;

  void _addSubject(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.newSubject);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  SfSpacing.screen,
                  SfSpacing.lg,
                  SfSpacing.screen,
                  SfSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Paso 1 de 2',
                      style: SfTypography.caption.copyWith(color: SfColors.primaryLight),
                    ),
                    const SizedBox(height: SfSpacing.xxs),
                    Text('Agrega tus materias', style: SfTypography.h1),
                    const SizedBox(height: SfSpacing.xs),
                    Text(
                      'Con tu horario y los porcentajes calculamos tu nota y '
                      'organizamos tu semana.',
                      style: SfTypography.body.copyWith(color: SfColors.textSecondary),
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    if (subjects.isEmpty)
                      const SfEmptyState(
                        icon: Icons.menu_book_outlined,
                        title: 'Aún no tienes materias',
                        message: 'Toca "Agregar materia" para registrar la primera y '
                            'calcular tu nota.',
                      )
                    else
                      for (final subject in subjects) ...[
                        SubjectSetupTile(
                          subject: subject,
                          onTap: () => _addSubject(context),
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SfSpacing.screen,
                SfSpacing.xs,
                SfSpacing.screen,
                SfSpacing.md,
              ),
              child: SfButton(
                label: 'Continuar',
                onPressed: subjects.isEmpty
                    ? null
                    : () => Navigator.pushNamed(context, AppRoutes.setupReminders),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
