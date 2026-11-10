import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/subjects/data/subjects_repository_impl.dart';
import 'package:studyflow/features/subjects/ui/bloc/subject_detail_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/subject_detail_state.dart';
import 'package:studyflow/features/subjects/ui/widgets/formato_materias.dart';
import 'package:studyflow/features/subjects/ui/widgets/grade_component_row.dart';
import 'package:studyflow/features/subjects/ui/widgets/subject_grade_card.dart';

/// Detalle de una materia (Figma 22).
///
/// Recibe una [Materia] como argumento de la ruta. Si llega sin argumento no
/// se rompe: muestra la primera materia del periodo.
class SubjectDetailScreen extends StatelessWidget {
  const SubjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final argumento = ModalRoute.of(context)?.settings.arguments;
    final materia = argumento is Materia ? argumento : null;

    return BlocProvider(
      create: (_) =>
          SubjectDetailCubit(SubjectsRepositoryImpl(supabase), materia: materia)
            ..cargar(),
      child: const _SubjectDetailView(),
    );
  }
}

class _SubjectDetailView extends StatelessWidget {
  const _SubjectDetailView();

  Future<void> _registrarNota(BuildContext context, Materia materia) async {
    final cubit = context.read<SubjectDetailCubit>();
    await Navigator.pushNamed(
      context,
      AppRoutes.registerGrade,
      arguments: materia,
    );
    cubit.cargar(mostrarCargando: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Materia'),
            Expanded(
              child: BlocBuilder<SubjectDetailCubit, SubjectDetailState>(
                builder: (context, state) => switch (state) {
                  SubjectDetailLoading() => const SfLoadingState(
                    message: 'Cargando la materia...',
                  ),
                  SubjectDetailError(:final mensaje) => Center(
                    child: SingleChildScrollView(
                      child: SfErrorState(
                        message: mensaje,
                        onRetry: () =>
                            context.read<SubjectDetailCubit>().cargar(),
                      ),
                    ),
                  ),
                  SubjectDetailEmpty() => const Center(
                    child: SingleChildScrollView(
                      child: SfEmptyState(
                        icon: Icons.menu_book_outlined,
                        title: 'Aún no tienes materias',
                        message:
                            'Agrega una materia desde la pestaña Materias para ver su detalle.',
                      ),
                    ),
                  ),
                  final SubjectDetailLoaded cargado => _contenido(
                    context,
                    cargado,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido(BuildContext context, SubjectDetailLoaded state) {
    final materia = state.materia;
    final horario = horarioTexto(materia.horarios);
    final subtitulo = [
      if (materia.profesor != null) materia.profesor!,
      if (horario != null) horario,
    ].join(' · ');

    return RefreshIndicator(
      onRefresh: () =>
          context.read<SubjectDetailCubit>().cargar(mostrarCargando: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          SfSpacing.screen,
          SfSpacing.xs,
          SfSpacing.screen,
          SfSpacing.lg,
        ),
        children: [
          Text(materia.nombre, style: SfTypography.h1),
          if (subtitulo.isNotEmpty) ...[
            const SizedBox(height: SfSpacing.xxs),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: SfSpacing.md,
                  color: SfColors.textSecondary,
                ),
                const SizedBox(width: SfSpacing.xxs),
                Expanded(child: Text(subtitulo, style: SfTypography.caption)),
              ],
            ),
          ],
          const SizedBox(height: SfSpacing.md),
          SubjectGradeCard(materia: materia, resumen: state.resumen),
          const SizedBox(height: SfSpacing.sm),
          SfButton(
            label: 'Registrar nota',
            variant: SfButtonVariant.secondary,
            icon: Icons.star_outline_rounded,
            onPressed: () => _registrarNota(context, materia),
          ),
          const SizedBox(height: SfSpacing.lg),
          Text('Cómo se calcula tu nota', style: SfTypography.h2),
          const SizedBox(height: SfSpacing.xs),
          for (final componente in state.componentes)
            GradeComponentRow(resumen: componente),
          const SizedBox(height: SfSpacing.lg),
          Text('Actividades', style: SfTypography.h2),
          const SizedBox(height: SfSpacing.sm),
          if (state.actividades.isEmpty)
            const SfEmptyState(
              icon: Icons.checklist_rounded,
              title: 'Aún no hay actividades',
              message: 'Agrega una tarea de esta materia para verla aquí.',
            )
          else
            for (final item in state.actividades) ...[
              SfTaskTile(
                title: item.actividad.titulo,
                subtitle: item.tieneNota
                    ? '${item.actividad.componenteNombre ?? 'Actividad'} · nota ${notaTexto(item.calificacion!.nota)}'
                    : '${item.actividad.componenteNombre ?? 'Actividad'} · ${fechaCorta(item.actividad.fechaLimite)}',
                subjectColor: materia.color,
                done: item.actividad.estado.estaCerrada,
                trailing: item.tieneNota
                    ? SfBadge(
                        label: notaTexto(item.calificacion!.nota),
                        tone: SfTone.success,
                      )
                    : null,
              ),
              const SizedBox(height: SfSpacing.sm),
            ],
        ],
      ),
    );
  }
}
