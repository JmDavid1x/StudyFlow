import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/calendar/ui/widgets/formato.dart';
import 'package:studyflow/features/study_blocks/data/study_blocks_repository_impl.dart';
import 'package:studyflow/features/study_blocks/ui/bloc/study_block_cubit.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/block_completed_sheet.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/block_pending_sheet.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/discard_block_sheet.dart';

/// Bloque de estudio (Figma 27). Recibe un [BloqueEstudio] como argumento
/// (desde el calendario) y crea su propio StudyBlockCubit. Muestra qué tarea
/// prepara, cuándo es, cuánto dura, quién lo creó y el aviso.
class StudyBlockScreen extends StatelessWidget {
  const StudyBlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! BloqueEstudio) return const _SinBloque();
    return BlocProvider(
      create: (_) =>
          StudyBlockCubit(StudyBlocksRepositoryImpl(supabase), args)..cargar(),
      child: const _StudyBlockView(),
    );
  }
}

class _StudyBlockView extends StatefulWidget {
  const _StudyBlockView();

  @override
  State<_StudyBlockView> createState() => _StudyBlockViewState();
}

class _StudyBlockViewState extends State<_StudyBlockView> {
  @override
  void initState() {
    super.initState();
    // S10: si ya pasó la hora del bloque y sigue pendiente, se pregunta qué pasó.
    final bloque = context.read<StudyBlockCubit>().state.bloque;
    if (bloque.estado == EstadoBloque.pendiente &&
        bloque.fin.isBefore(DateTime.now())) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final cubit = context.read<StudyBlockCubit>();
        showBlockPendingSheet(
          context,
          bloque,
          alHacerlo: cubit.completar,
          alReprogramar: _reprogramar,
          alDescartar: cubit.descartar,
        );
      });
    }
  }

  /// Abre Nuevo bloque en modo reprogramar; si se guardó, vuelve al calendario.
  Future<void> _reprogramar() async {
    final bloque = context.read<StudyBlockCubit>().state.bloque;
    final messenger = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final guardado = await navegador.pushNamed(
      AppRoutes.newStudyBlock,
      arguments: bloque,
    );
    if (guardado == true) {
      navegador.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Bloque reprogramado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudyBlockCubit, StudyBlockState>(
      listenWhen: (antes, ahora) =>
          antes.resultado != ahora.resultado || antes.error != ahora.error,
      listener: (context, state) {
        switch (state.resultado) {
          case ResultadoBloque.completado:
            showBlockCompletedSheet(
              context,
              state.bloque,
              actividad: state.actividad,
            );
          case ResultadoBloque.descartado:
            discardBlockAndGoBack(context);
          case ResultadoBloque.ninguno:
            if (state.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
        }
      },
      builder: (context, state) {
        final bloque = state.bloque;
        final pendiente = bloque.estado == EstadoBloque.pendiente;
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SfScreenHeader(title: 'Bloque de estudio'),
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
                        SfBadge(
                          label: bloque.esDelAsistente
                              ? 'Creado por el asistente'
                              : 'Creado por ti',
                          tone: SfTone.info,
                        ),
                        const SizedBox(height: SfSpacing.xs),
                        Text(
                          bloque.actividadTitulo ?? 'Bloque de estudio',
                          style: SfTypography.h1,
                        ),
                        const SizedBox(height: SfSpacing.md),
                        _Datos(bloque: bloque),
                        const SizedBox(height: SfSpacing.md),
                        Text('Tarea vinculada', style: SfTypography.label),
                        const SizedBox(height: SfSpacing.xs - 2),
                        _TareaVinculada(actividad: state.actividad),
                        const SizedBox(height: SfSpacing.md),
                        SfCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 20,
                                color: SfColors.textSecondary,
                              ),
                              const SizedBox(width: SfSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Completar este bloque no completa la tarea. Cuando marques la tarea '
                                  'como completada, quitamos del calendario los bloques que te queden.',
                                  style: SfTypography.caption,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Solo un bloque pendiente se puede completar, mover o descartar.
                if (pendiente)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SfSpacing.screen,
                      SfSpacing.xs,
                      SfSpacing.screen,
                      SfSpacing.md,
                    ),
                    child: Column(
                      children: [
                        SfButton(
                          label: 'Completar bloque',
                          icon: Icons.check,
                          isLoading: state.procesando,
                          onPressed: () =>
                              context.read<StudyBlockCubit>().completar(),
                        ),
                        const SizedBox(height: SfSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child: SfButton(
                                label: 'Reprogramar',
                                variant: SfButtonVariant.secondary,
                                onPressed: state.procesando
                                    ? null
                                    : _reprogramar,
                              ),
                            ),
                            const SizedBox(width: SfSpacing.xs),
                            Expanded(
                              child: SfButton(
                                label: 'Descartar',
                                variant: SfButtonVariant.ghost,
                                onPressed: state.procesando
                                    ? null
                                    : () => showDiscardBlockSheet(
                                        context,
                                        bloque,
                                        alConfirmar: context
                                            .read<StudyBlockCubit>()
                                            .descartar,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tarjeta con día, hora, duración, aviso y estado del bloque.
class _Datos extends StatelessWidget {
  const _Datos({required this.bloque});

  final BloqueEstudio bloque;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.md),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Día',
            value: sfFormatDate(bloque.inicio),
          ),
          _InfoRow(
            icon: Icons.schedule,
            label: 'Hora',
            value: rangoHoras(bloque.inicio, bloque.fin),
          ),
          _InfoRow(
            icon: Icons.timelapse,
            label: 'Duración',
            value: duracionTexto(bloque.duracion),
          ),
          _InfoRow(
            icon: Icons.alarm,
            label: 'Aviso',
            value: bloque.avisoMin == null || bloque.avisoMin == 0
                ? 'Sin aviso'
                : '${bloque.avisoMin} min antes',
          ),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: 'Estado',
            value: switch (bloque.estado) {
              EstadoBloque.pendiente => 'Pendiente',
              EstadoBloque.completado => 'Completado',
              EstadoBloque.descartado => 'Descartado',
              EstadoBloque.cancelado => 'Cancelado',
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

/// La actividad que prepara el bloque. Al tocarla abre su detalle.
class _TareaVinculada extends StatelessWidget {
  const _TareaVinculada({required this.actividad});

  final Actividad? actividad;

  @override
  Widget build(BuildContext context) {
    final tarea = actividad;
    if (tarea == null) {
      return Text('Cargando la tarea...', style: SfTypography.caption);
    }
    return SfCard(
      onTap: () => Navigator.pushNamed(
        context,
        tarea.esExamen ? AppRoutes.examDetail : AppRoutes.taskDetail,
        arguments: tarea,
      ),
      child: Row(
        children: [
          Container(
            width: SfSpacing.xs,
            height: SfSpacing.xs,
            decoration: BoxDecoration(
              color: tarea.materiaColor ?? SfColors.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tarea.titulo, style: SfTypography.bodyStrong),
                Text(
                  [
                    ?tarea.materiaNombre,
                    '${tarea.esExamen ? 'examen' : 'entrega'} ${sfFormatDate(tarea.fechaLimite)}',
                  ].join(' · '),
                  style: SfTypography.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: SfColors.textSecondary),
        ],
      ),
    );
  }
}

/// Si la pantalla se abre sin bloque, no se rompe.
class _SinBloque extends StatelessWidget {
  const _SinBloque();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Bloque de estudio'),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: SfEmptyState(
                    icon: Icons.event_busy_outlined,
                    title: 'No encontramos el bloque',
                    message: 'Ábrelo de nuevo desde el calendario.',
                    actionLabel: 'Volver',
                    onAction: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de dato del bloque: ícono, nombre y valor a la derecha.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SfSpacing.sm),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: SfColors.border))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: SfColors.primaryLight),
          const SizedBox(width: SfSpacing.sm),
          Text(
            label,
            style: SfTypography.body.copyWith(color: SfColors.textSecondary),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: SfTypography.bodyStrong,
            ),
          ),
        ],
      ),
    );
  }
}
