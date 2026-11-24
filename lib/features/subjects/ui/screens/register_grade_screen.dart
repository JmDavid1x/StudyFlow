import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/subjects/data/subjects_repository_impl.dart';
import 'package:studyflow/features/subjects/ui/bloc/register_grade_cubit.dart';
import 'package:studyflow/features/subjects/ui/bloc/register_grade_state.dart';
import 'package:studyflow/features/subjects/ui/widgets/component_selector.dart';
import 'package:studyflow/features/subjects/ui/widgets/formato_materias.dart';
import 'package:studyflow/features/subjects/ui/widgets/grade_stepper.dart';

/// Registrar nota (Figma 23). Al guardar abre la hoja S3 "Nota registrada".
///
/// Recibe una [Materia] (desde el detalle) o una [Actividad] (desde el detalle
/// de examen: queda preseleccionada). Si llega sin argumento no se rompe: usa
/// la primera materia del periodo.
class RegisterGradeScreen extends StatelessWidget {
  const RegisterGradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final argumento = ModalRoute.of(context)?.settings.arguments;

    return BlocProvider(
      create: (_) => RegisterGradeCubit(
        SubjectsRepositoryImpl(supabase),
        materia: argumento is Materia ? argumento : null,
        actividad: argumento is Actividad ? argumento : null,
      )..cargar(),
      child: const _RegisterGradeView(),
    );
  }
}

class _RegisterGradeView extends StatelessWidget {
  const _RegisterGradeView();

  Future<void> _mostrarResultado(
    BuildContext context,
    NotaGuardada guardada,
  ) async {
    final antes = guardada.antes;
    final despues = guardada.despues;
    final mensaje = despues == null
        ? 'Guardamos tu nota en ${guardada.materiaNombre}.'
        : antes == null
        ? 'Tu nota acumulada en ${guardada.materiaNombre} es ${notaTexto(despues)}.'
        : (despues - antes).abs() < 0.05
        ? 'Tu nota acumulada en ${guardada.materiaNombre} se mantiene en ${notaTexto(despues)}.'
        : 'Tu nota acumulada en ${guardada.materiaNombre} ${despues > antes ? 'subió' : 'bajó'} '
              'de ${notaTexto(antes)} a ${notaTexto(despues)}.';

    await showSfBottomSheet<void>(
      context,
      builder: (sheetContext) => SfResultSheet(
        title: 'Nota registrada',
        message: mensaje,
        primaryLabel: 'Listo',
        onPrimary: () => Navigator.pop(sheetContext),
      ),
    );
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterGradeCubit, RegisterGradeState>(
      listenWhen: (anterior, actual) {
        if (actual is! RegisterGradeReady) return false;
        final antes = anterior is RegisterGradeReady ? anterior : null;
        return (antes?.guardada == null && actual.guardada != null) ||
            (antes?.errorAlGuardar != actual.errorAlGuardar &&
                actual.errorAlGuardar != null);
      },
      listener: (context, state) {
        if (state is! RegisterGradeReady) return;
        if (state.guardada != null) {
          _mostrarResultado(context, state.guardada!);
        } else if (state.errorAlGuardar != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorAlGuardar!)));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SfScreenHeader(title: 'Registrar nota', useCloseIcon: true),
              Expanded(
                child: BlocBuilder<RegisterGradeCubit, RegisterGradeState>(
                  builder: (context, state) => switch (state) {
                    RegisterGradeLoading() => const SfLoadingState(
                      message: 'Cargando las actividades...',
                    ),
                    RegisterGradeError(:final mensaje) => Center(
                      child: SingleChildScrollView(
                        child: SfErrorState(
                          message: mensaje,
                          onRetry: () =>
                              context.read<RegisterGradeCubit>().cargar(),
                        ),
                      ),
                    ),
                    RegisterGradeEmpty(:final mensaje) => Center(
                      child: SingleChildScrollView(
                        child: SfEmptyState(
                          icon: Icons.checklist_rounded,
                          title: 'Nada que calificar',
                          message: mensaje,
                        ),
                      ),
                    ),
                    final RegisterGradeReady listo => _formulario(
                      context,
                      listo,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context, RegisterGradeReady state) {
    final cubit = context.read<RegisterGradeCubit>();
    final componentes = state.componentes;
    final indiceComponente = componentes.indexWhere(
      (c) => c.id == state.componenteId,
    );
    final despues = state.despues;
    final antes = state.antes;
    final textoMeta = despues == null
        ? null
        : textoParaLaMeta(meta: state.materia.metaNota, resumen: despues);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SfSpacing.screen,
              SfSpacing.xs,
              SfSpacing.screen,
              SfSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.materia.nombre,
                  style: SfTypography.label.copyWith(
                    color: SfColors.primaryLight,
                  ),
                ),
                const SizedBox(height: SfSpacing.sm),
                Text('Componente', style: SfTypography.label),
                const SizedBox(height: SfSpacing.xs),
                ComponentSelector(
                  components: componentes,
                  selected: indiceComponente < 0 ? 0 : indiceComponente,
                  onChanged: (index) =>
                      cubit.elegirComponente(componentes[index].id),
                ),
                const SizedBox(height: SfSpacing.md),
                Text('Actividad', style: SfTypography.label),
                const SizedBox(height: SfSpacing.xs),
                if (state.visibles.isEmpty)
                  Text(
                    'Este componente aún no tiene actividades.',
                    style: SfTypography.caption,
                  )
                else
                  SfOptionCards<String>(
                    columns: 1,
                    selected: state.actividadId,
                    onChanged: cubit.elegirActividad,
                    options: [
                      for (final item in state.visibles)
                        SfOption<String>(
                          value: item.actividad.id,
                          label: item.actividad.titulo,
                          subtitle: item.tieneNota
                              ? 'Nota actual ${notaTexto(item.calificacion!.nota)}'
                              : fechaCorta(item.actividad.fechaLimite),
                        ),
                    ],
                  ),
                const SizedBox(height: SfSpacing.md),
                Text('Nota obtenida', style: SfTypography.label),
                const SizedBox(height: SfSpacing.xs),
                GradeStepper(
                  tenths: state.decimas,
                  onChanged: cubit.cambiarDecimas,
                ),
                const SizedBox(height: SfSpacing.xs),
                Text('Escala de 0.0 a 5.0', style: SfTypography.caption),
                if (despues != null) ...[
                  const SizedBox(height: SfSpacing.md),
                  _AccumulatedPreview(
                    antes: antes.notaAcumulada,
                    despues: despues.notaAcumulada,
                    evaluado: despues.porcentajeEvaluado,
                    textoMeta: textoMeta,
                  ),
                ],
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
            label: 'Guardar nota',
            onPressed: state.puedeGuardar ? cubit.guardar : null,
          ),
        ),
      ],
    );
  }
}

/// "Así queda tu nota acumulada": antes y después de guardar.
class _AccumulatedPreview extends StatelessWidget {
  const _AccumulatedPreview({
    required this.antes,
    required this.despues,
    required this.evaluado,
    required this.textoMeta,
  });

  final double? antes;
  final double? despues;
  final double evaluado;
  final String? textoMeta;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Así queda tu nota acumulada',
            style: SfTypography.label.copyWith(color: SfColors.primaryLight),
          ),
          const SizedBox(height: SfSpacing.xs),
          Row(
            children: [
              Text(
                notaTexto(antes),
                style: SfTypography.h1.copyWith(color: SfColors.textSecondary),
              ),
              const SizedBox(width: SfSpacing.sm),
              const Icon(
                Icons.arrow_forward_rounded,
                size: SfSpacing.md,
                color: SfColors.textSecondary,
              ),
              const SizedBox(width: SfSpacing.sm),
              Text(notaTexto(despues), style: SfTypography.h1),
            ],
          ),
          const SizedBox(height: SfSpacing.xs),
          Text(
            'Con el ${evaluado.round()} % evaluado.${textoMeta == null ? '' : ' $textoMeta.'}',
            style: SfTypography.body,
          ),
        ],
      ),
    );
  }
}
