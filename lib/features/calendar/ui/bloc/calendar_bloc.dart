import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/calendar/domain/agenda_del_dia.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/calendar/domain/horario_materia.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_event.dart';
import 'package:studyflow/features/calendar/ui/bloc/calendar_state.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/completar_bloque.dart';

/// Maneja la pestaña Calendario (Figma 20): pide a Supabase la semana del día
/// elegido (clases, entregas y bloques) y completa bloques desde la agenda.
///
/// Elegir otro día de la misma semana no vuelve a pedir nada: la agenda se
/// arma con lo que ya está en el estado.
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  /// GetIt le entrega el repositorio y el caso de uso (calendar_di.dart).
  /// [ahora] solo se usa en los tests, para fijar la fecha de "hoy".
  CalendarBloc(
    this._calendario,
    StudyBlocksRepository bloques, {
    CompletarBloque? completar,
    DateTime Function()? ahora,
  }) : _completar = completar ?? CompletarBloque(bloques),
       super(CalendarState(dia: _soloDia((ahora ?? DateTime.now)()))) {
    on<CalendarioIniciado>((_, emit) => _cargar(emit, state.dia));
    // Las recargas (al volver o en vivo) van una detrás de otra: si llegan
    // varios cambios seguidos, ninguna recarga pisa a la siguiente.
    on<CalendarioRecargado>(
      (_, emit) => _cargar(emit, state.dia),
      transformer: (eventos, mapper) => eventos.asyncExpand(mapper),
    );
    on<DiaElegido>(_alElegirDia);
    on<SemanaCambiada>(
      (event, emit) => _cargar(
        emit,
        DateTime(
          state.dia.year,
          state.dia.month,
          state.dia.day + 7 * event.semanas,
        ),
      ),
    );
    on<BloqueCompletado>(_alCompletar);
  }

  final CalendarRepository _calendario;
  final CompletarBloque _completar;

  /// Los horarios no cambian de una semana a otra: se piden una sola vez.
  List<HorarioMateria>? _horarios;

  static DateTime _soloDia(DateTime t) => DateTime(t.year, t.month, t.day);

  Future<void> _cargar(Emitter<CalendarState> emit, DateTime dia) async {
    // Si ya hay agenda, se deja a la vista mientras llega la nueva semana.
    if (state.status != CalendarStatus.listo) {
      emit(state.copyWith(status: CalendarStatus.cargando, dia: dia));
    }
    try {
      final desde = inicioDeSemana(dia);
      final hasta = DateTime(desde.year, desde.month, desde.day + 7);
      _horarios ??= await _calendario.horarios();
      final actividades = await _calendario.actividadesEntre(desde, hasta);
      final bloques = await _calendario.bloquesEntre(desde, hasta);
      emit(
        state.copyWith(
          status: CalendarStatus.listo,
          dia: dia,
          horarios: _horarios,
          actividades: actividades,
          bloques: bloques,
        ),
      );
    } on AppException catch (e) {
      _horarios = null;
      emit(
        state.copyWith(
          status: CalendarStatus.error,
          dia: dia,
          error: e.mensaje,
        ),
      );
    }
  }

  Future<void> _alElegirDia(
    DiaElegido event,
    Emitter<CalendarState> emit,
  ) async {
    final dia = _soloDia(event.dia);
    if (inicioDeSemana(dia) == state.semana &&
        state.status == CalendarStatus.listo) {
      emit(state.copyWith(dia: dia));
    } else {
      await _cargar(emit, dia);
    }
  }

  Future<void> _alCompletar(
    BloqueCompletado event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      await _completar(event.bloque);
      emit(state.copyWith(completado: event.bloque));
      // Se recarga para ver el bloque marcado y la actividad en progreso.
      await _cargar(emit, state.dia);
    } on AppException catch (e) {
      emit(state.copyWith(errorAccion: e.mensaje));
    }
  }
}
