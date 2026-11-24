import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/subjects/data/subjects_repository_impl.dart';
import 'package:studyflow/features/subjects/domain/usecases/obtener_resumen_semestre.dart';
import 'package:studyflow/features/subjects/ui/bloc/subjects_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/subjects_state.dart';
import 'package:studyflow/features/subjects/ui/widgets/dashed_add_button.dart';
import 'package:studyflow/features/subjects/ui/widgets/semester_average_card.dart';
import 'package:studyflow/features/subjects/ui/widgets/subject_progress_card.dart';

/// Pestaña Materias (Figma 21).
///
/// Resumen del semestre y una tarjeta por materia con su nota actual y su
/// meta. No lleva barra inferior: la pone MainShell. Crea su propio Cubit.
class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubjectsCubit(
        ObtenerResumenSemestre(SubjectsRepositoryImpl(supabase)),
      )..cargar(),
      child: const _SubjectsView(),
    );
  }
}

class _SubjectsView extends StatelessWidget {
  const _SubjectsView();

  /// Va a otra pantalla y, al volver, recarga: otro integrante pudo cambiar los datos.
  Future<void> _abrir(
    BuildContext context,
    String ruta, {
    Object? argumentos,
  }) async {
    final cubit = context.read<SubjectsCubit>();
    await Navigator.pushNamed(context, ruta, arguments: argumentos);
    cubit.cargar(mostrarCargando: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SfLargeTitle(title: 'Materias'),
            Expanded(
              child: BlocBuilder<SubjectsCubit, SubjectsState>(
                builder: (context, state) => switch (state) {
                  SubjectsLoading() => const SfLoadingState(
                    message: 'Cargando tus materias...',
                  ),
                  SubjectsError(:final mensaje) => Center(
                    child: SingleChildScrollView(
                      child: SfErrorState(
                        message: mensaje,
                        onRetry: () => context.read<SubjectsCubit>().cargar(),
                      ),
                    ),
                  ),
                  SubjectsEmpty() => Center(
                    child: SingleChildScrollView(
                      child: SfEmptyState(
                        icon: Icons.menu_book_outlined,
                        title: 'Aún no tienes materias',
                        message:
                            'Agrega tu primera materia para calcular tu nota y organizar tu semana.',
                        actionLabel: 'Agregar materia',
                        onAction: () => _abrir(context, AppRoutes.newSubject),
                      ),
                    ),
                  ),
                  SubjectsLoaded(:final resumen) => RefreshIndicator(
                    onRefresh: () => context.read<SubjectsCubit>().cargar(
                      mostrarCargando: false,
                    ),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        SfSpacing.screen,
                        SfSpacing.xs,
                        SfSpacing.screen,
                        SfSpacing.lg,
                      ),
                      children: [
                        SemesterAverageCard(
                          promedio: resumen.promedio,
                          cantidadMaterias: resumen.materias.length,
                        ),
                        const SizedBox(height: SfSpacing.sm),
                        for (final item in resumen.materias) ...[
                          SubjectProgressCard(
                            item: item,
                            onTap: () => _abrir(
                              context,
                              AppRoutes.subjectDetail,
                              argumentos: item.materia,
                            ),
                          ),
                          const SizedBox(height: SfSpacing.sm),
                        ],
                        DashedAddButton(
                          label: 'Agregar materia',
                          onPressed: () =>
                              _abrir(context, AppRoutes.newSubject),
                        ),
                      ],
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
