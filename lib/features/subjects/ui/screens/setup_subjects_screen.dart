import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/subjects/data/subjects_repository_impl.dart';
import 'package:studyflow/features/subjects/ui/bloc/setup_subjects_cubit.dart';
import 'package:studyflow/features/subjects/ui/widgets/dashed_add_button.dart';
import 'package:studyflow/features/subjects/ui/widgets/subject_setup_tile.dart';

/// Tus materias, paso 1 de la configuración inicial (Figma 08).
///
/// Lista las materias agregadas y deja agregar otra. "Continuar" lleva al
/// paso 2: activar recordatorios.
class SetupSubjectsScreen extends StatelessWidget {
  const SetupSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SetupSubjectsCubit(SubjectsRepositoryImpl(supabase))..cargar(),
      child: const _SetupSubjectsView(),
    );
  }
}

class _SetupSubjectsView extends StatelessWidget {
  const _SetupSubjectsView();

  Future<void> _addSubject(BuildContext context) async {
    final cubit = context.read<SetupSubjectsCubit>();
    await Navigator.pushNamed(context, AppRoutes.newSubject);
    cubit.cargar(mostrarCargando: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SetupSubjectsCubit, SetupSubjectsState>(
          builder: (context, state) {
            final materias = state is SetupSubjectsLoaded
                ? state.materias
                : const [];
            return Column(
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
                          style: SfTypography.caption.copyWith(
                            color: SfColors.primaryLight,
                          ),
                        ),
                        const SizedBox(height: SfSpacing.xxs),
                        Text('Agrega tus materias', style: SfTypography.h1),
                        const SizedBox(height: SfSpacing.xs),
                        Text(
                          'Con tu horario y los porcentajes calculamos tu nota y organizamos tu semana.',
                          style: SfTypography.body.copyWith(
                            color: SfColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: SfSpacing.lg),
                        ..._contenido(context, state),
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
                    onPressed: materias.isEmpty
                        ? null
                        : () => Navigator.pushNamed(
                            context,
                            AppRoutes.setupReminders,
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _contenido(BuildContext context, SetupSubjectsState state) {
    switch (state) {
      case SetupSubjectsLoading():
        return const [
          SizedBox(height: SfSpacing.xl),
          SfLoadingState(message: 'Cargando tus materias...'),
        ];
      case SetupSubjectsError(:final mensaje):
        return [
          SfErrorState(
            message: mensaje,
            onRetry: () => context.read<SetupSubjectsCubit>().cargar(),
          ),
        ];
      case SetupSubjectsLoaded(:final materias):
        return [
          if (materias.isEmpty)
            const SfEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Aún no tienes materias',
              message:
                  'Toca "Agregar materia" para registrar la primera y calcular tu nota.',
            )
          else
            for (final materia in materias) ...[
              SubjectSetupTile(
                materia: materia,
                onTap: () => _addSubject(context),
              ),
              const SizedBox(height: SfSpacing.sm),
            ],
          DashedAddButton(
            label: 'Agregar materia',
            onPressed: () => _addSubject(context),
          ),
        ];
    }
  }
}
