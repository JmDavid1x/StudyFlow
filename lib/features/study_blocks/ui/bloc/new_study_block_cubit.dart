import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/crear_bloque.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/reprogramar_bloque.dart';

enum NewStudyBlockStatus { cargando, listo, error }

class NewStudyBlockState extends Equatable {
  const NewStudyBlockState({
    this.status = NewStudyBlockStatus.cargando,
    this.actividades = const [],
    this.errorCarga,
    this.guardando = false,
    this.errorGuardar,
    this.guardado = false,
  });

  final NewStudyBlockStatus status;

  /// Actividades abiertas del periodo activo, para elegir qué preparar.
  final List<Actividad> actividades;
  final String? errorCarga;
  final bool guardando;

  /// Por qué no se guardó (por ejemplo, "Se cruza con tu clase de...").
  final String? errorGuardar;

  /// true cuando ya quedó guardado: la pantalla vuelve atrás.
  final bool guardado;

  NewStudyBlockState copyWith({
    NewStudyBlockStatus? status,
    List<Actividad>? actividades,
    String? errorCarga,
    bool? guardando,
    String? errorGuardar,
    bool? guardado,
  }) => NewStudyBlockState(
    status: status ?? this.status,
    actividades: actividades ?? this.actividades,
    errorCarga: errorCarga,
    guardando: guardando ?? this.guardando,
    errorGuardar: errorGuardar,
    guardado: guardado ?? this.guardado,
  );

  @override
  List<Object?> get props => [
    status,
    actividades,
    errorCarga,
    guardando,
    errorGuardar,
    guardado,
  ];
}

/// Maneja Nuevo bloque (Figma 28) y Reprogramar: carga las actividades
/// abiertas y guarda el bloque solo si no se cruza con clases ni con otros
/// bloques pendientes.
class NewStudyBlockCubit extends Cubit<NewStudyBlockState> {
  /// GetIt le entrega los repositorios y los casos de uso
  /// (study_blocks_di.dart). Si no llegan, se arman con los repositorios.
  NewStudyBlockCubit(
    StudyBlocksRepository bloques,
    CalendarRepository calendario, {
    CrearBloque? crear,
    ReprogramarBloque? reprogramar,
  }) : _bloques = bloques,
       _crear = crear ?? CrearBloque(bloques, calendario),
       _reprogramar = reprogramar ?? ReprogramarBloque(bloques, calendario),
       super(const NewStudyBlockState());

  final StudyBlocksRepository _bloques;
  final CrearBloque _crear;
  final ReprogramarBloque _reprogramar;

  Future<void> cargar() async {
    emit(const NewStudyBlockState());
    try {
      final actividades = await _bloques.actividadesAbiertas();
      emit(
        NewStudyBlockState(
          status: NewStudyBlockStatus.listo,
          actividades: actividades,
        ),
      );
    } on AppException catch (e) {
      emit(
        NewStudyBlockState(
          status: NewStudyBlockStatus.error,
          errorCarga: e.mensaje,
        ),
      );
    }
  }

  /// Crea un bloque para [actividadId] o, con [reprogramar], mueve ese bloque.
  Future<void> guardar({
    required DateTime inicio,
    required int minutos,
    String? actividadId,
    int? avisoMin,
    BloqueEstudio? reprogramar,
  }) async {
    if (state.guardando) return;
    emit(state.copyWith(guardando: true));
    final fin = inicio.add(Duration(minutes: minutos));
    try {
      if (reprogramar != null) {
        await _reprogramar(reprogramar, inicio: inicio, fin: fin);
      } else {
        await _crear(
          actividadId: actividadId!,
          inicio: inicio,
          fin: fin,
          avisoMin: avisoMin,
        );
      }
      emit(state.copyWith(guardando: false, guardado: true));
    } on AppException catch (e) {
      emit(state.copyWith(guardando: false, errorGuardar: e.mensaje));
    }
  }
}
