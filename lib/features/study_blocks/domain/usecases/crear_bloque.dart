import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/study_blocks/domain/validar_bloque.dart';

/// Crea un bloque de estudio pendiente para una actividad, solo si no se
/// cruza con una clase ni con otro bloque pendiente.
class CrearBloque {
  const CrearBloque(this._bloques, this._calendario);

  final StudyBlocksRepository _bloques;
  final CalendarRepository _calendario;

  Future<BloqueEstudio> call({
    required String actividadId,
    required DateTime inicio,
    required DateTime fin,
    int? avisoMin,
  }) async {
    final error = await revisarCruces(_calendario, inicio: inicio, fin: fin);
    if (error != null) throw AppException(error);
    return _bloques.crearBloque(
      BloqueEstudio(
        id: '',
        actividadId: actividadId,
        inicio: inicio,
        fin: fin,
        estado: EstadoBloque.pendiente,
        avisoMin: avisoMin,
      ),
    );
  }
}

/// Trae las clases y los bloques de los días que toca el intervalo y lo
/// valida con [validarBloque]. Lo usan crear y reprogramar.
Future<String?> revisarCruces(
  CalendarRepository calendario, {
  required DateTime inicio,
  required DateTime fin,
  String? ignorar,
}) async {
  if (!fin.isAfter(inicio)) {
    return 'La hora de fin debe ser después de la de inicio.';
  }
  final desde = DateTime(inicio.year, inicio.month, inicio.day);
  final hasta = DateTime(fin.year, fin.month, fin.day + 1);
  final horarios = await calendario.horarios();
  final bloques = await calendario.bloquesEntre(desde, hasta);
  return validarBloque(
    inicio: inicio,
    fin: fin,
    horarios: horarios,
    bloques: bloques,
    ignorar: ignorar,
  );
}
