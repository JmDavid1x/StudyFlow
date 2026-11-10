import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/calendar/data/calendar_repository_impl.dart';
import 'package:studyflow/features/calendar/domain/agenda_del_dia.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_bloc.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_event.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_state.dart';
import 'package:studyflow/features/calendar/ui/widgets/add_sheet.dart';
import 'package:studyflow/features/calendar/ui/widgets/agenda_item_tile.dart';
import 'package:studyflow/features/calendar/ui/widgets/calendar_labels.dart';
import 'package:studyflow/features/calendar/ui/widgets/month_header.dart';
import 'package:studyflow/features/calendar/ui/widgets/week_strip.dart';
import 'package:studyflow/features/study_blocks/data/study_blocks_repository_impl.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/block_completed_sheet.dart';

/// Pestaña Calendario (Figma 20). MainShell la crea con `const CalendarScreen()`,
/// así que la pantalla crea su propio CalendarBloc con los repositorios de
/// Supabase. La barra inferior la pone MainShell.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalendarBloc(
        CalendarRepositoryImpl(supabase),
        StudyBlocksRepositoryImpl(supabase),
      )..add(const CalendarioIniciado()),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  /// Abre otra pantalla y, al volver, recarga la semana: otro integrante
  /// (o el usuario en esa pantalla) pudo cambiar los datos.
  Future<void> _abrir(BuildContext context, String ruta, Object? datos) async {
    final bloc = context.read<CalendarBloc>();
    await Navigator.pushNamed(context, ruta, arguments: datos);
    bloc.add(const CalendarioRecargado());
  }

  void _abrirEntrada(BuildContext context, EntradaAgenda entrada) {
    switch (entrada) {
      case BloqueEnAgenda(:final bloque):
        _abrir(context, AppRoutes.studyBlock, bloque);
      case EntregaEnAgenda(:final actividad):
        _abrir(
          context,
          actividad.esExamen ? AppRoutes.examDetail : AppRoutes.taskDetail,
          actividad,
        );
      case ClaseEnAgenda():
        break; // Las clases no abren ninguna pantalla.
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CalendarBloc>();
    return Scaffold(
      floatingActionButton: SfFab(
        onPressed: () => showAddSheet(
          context,
          alVolver: () => bloc.add(const CalendarioRecargado()),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<CalendarBloc, CalendarState>(
          listenWhen: (antes, ahora) =>
              antes.completado != ahora.completado ||
              antes.errorAccion != ahora.errorAccion,
          listener: (context, state) {
            final completado = state.completado;
            if (completado != null) {
              showBlockCompletedSheet(context, completado);
            } else if (state.errorAccion != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorAccion!)));
            }
          },
          builder: (context, state) => ListView(
            // Espacio abajo para que el botón + no tape la última fila.
            padding: const EdgeInsets.only(bottom: SfSpacing.xxl * 2),
            children: [
              const SfLargeTitle(title: 'Calendario'),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SfSpacing.screen,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MonthHeader(
                      date: state.semana,
                      onPrevious: () => bloc.add(const SemanaCambiada(-1)),
                      onNext: () => bloc.add(const SemanaCambiada(1)),
                    ),
                    const SizedBox(height: SfSpacing.sm),
                    WeekStrip(
                      weekStart: state.semana,
                      selected: state.dia,
                      onSelect: (dia) => bloc.add(DiaElegido(dia)),
                      dotsFor: (dia) => _puntos(state, dia),
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    ..._contenido(context, state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Puntos de un día: un color por cada pendiente (bloques en SfColors.info,
  /// entregas con el color de su materia).
  List<Color> _puntos(CalendarState state, DateTime dia) {
    if (!state.tienePunto(dia)) return const [];
    final agenda = agendaDelDia(
      dia,
      horarios: const [],
      actividades: state.actividades,
      bloques: state.bloques,
    );
    return [
      for (final entrada in agenda)
        switch (entrada) {
          BloqueEnAgenda(:final bloque)
              when bloque.estado == EstadoBloque.pendiente =>
            SfColors.info,
          EntregaEnAgenda(:final actividad)
              when !actividad.estado.estaCerrada =>
            actividad.materiaColor ?? SfColors.primaryLight,
          _ => null,
        },
    ].nonNulls.toList();
  }

  List<Widget> _contenido(BuildContext context, CalendarState state) {
    switch (state.status) {
      case CalendarStatus.cargando:
        return const [
          SizedBox(height: SfSpacing.xxl),
          SfLoadingState(message: 'Cargando tu semana...'),
        ];
      case CalendarStatus.error:
        return [
          SfErrorState(
            message: state.error ?? 'No pudimos cargar tu semana.',
            onRetry: () =>
                context.read<CalendarBloc>().add(const CalendarioRecargado()),
          ),
        ];
      case CalendarStatus.listo:
        final agenda = state.agenda;
        final pendientes = state.pendientes;
        final hoy = DateTime.now();
        final esHoy = mismoDia(state.dia, hoy);
        return [
          Row(
            children: [
              Expanded(
                child: Text(
                  esHoy
                      ? 'Hoy, ${CalendarLabels.dayTitle(state.dia).toLowerCase()}'
                      : CalendarLabels.dayTitle(state.dia),
                  style: SfTypography.h2,
                ),
              ),
              Text(
                switch (pendientes) {
                  0 => 'Libre',
                  1 => '1 pendiente',
                  _ => '$pendientes pendientes',
                },
                style: SfTypography.label.copyWith(
                  color: pendientes == 0
                      ? SfColors.textSecondary
                      : SfColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: SfSpacing.md),
          if (agenda.isEmpty)
            SfCard(
              child: SfEmptyState(
                icon: Icons.event_available_outlined,
                title: 'No tienes nada este día',
                message: 'Aprovecha para adelantar algo.',
                actionLabel: 'Agregar bloque de estudio',
                onAction: () => _abrir(context, AppRoutes.newStudyBlock, null),
              ),
            )
          else
            for (final entrada in agenda) ...[
              AgendaItemTile(
                entrada: entrada,
                onTap: entrada is ClaseEnAgenda
                    ? null
                    : () => _abrirEntrada(context, entrada),
                onComplete: switch (entrada) {
                  BloqueEnAgenda(:final bloque) =>
                    () => context.read<CalendarBloc>().add(
                      BloqueCompletado(bloque),
                    ),
                  _ => null,
                },
              ),
              const SizedBox(height: SfSpacing.sm),
            ],
          const SizedBox(height: SfSpacing.xs),
          Text(
            'Los puntos marcan los días con entregas o bloques sin completar.',
            style: SfTypography.caption,
          ),
        ];
    }
  }
}
