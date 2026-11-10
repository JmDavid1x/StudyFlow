import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';
import 'package:studyflow/features/study_blocks/domain/usecases/crear_bloque.dart';

/// Mueve un bloque pendiente a otra hora (también desde S10, cuando ya pasó
/// su hora). La nueva hora no puede cruzarse con clases ni con otros bloques.
class ReprogramarBloque {
  const ReprogramarBloque(this._bloques, this._calendario);

  final StudyBlocksRepository _bloques;
  final CalendarRepository _calendario;

  Future<void> call(
    BloqueEstudio bloque, {
    required DateTime inicio,
    required DateTime fin,
  }) async {
    if (bloque.estado != EstadoBloque.pendiente) {
      throw const AppException(
        'Solo se puede reprogramar un bloque pendiente.',
      );
    }
    final error = await revisarCruces(
      _calendario,
      inicio: inicio,
      fin: fin,
      ignorar: bloque.id,
    );
    if (error != null) throw AppException(error);
    await _bloques.reprogramarBloque(bloque.id, inicio, fin);
  }
}
