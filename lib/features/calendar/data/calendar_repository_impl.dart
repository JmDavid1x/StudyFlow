import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/calendar/domain/calendar_repository.dart';
import 'package:studyflow/features/calendar/domain/horario_materia.dart';

/// [CalendarRepository] con Supabase. No filtra por usuario: RLS ya devuelve
/// solo las filas de quien tiene la sesión.
class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._db);

  final SupabaseClient _db;

  @override
  Future<List<HorarioMateria>> horarios() async {
    try {
      final filas = await _db
          .from('materias')
          .select('${Materia.select}, periodos!inner(activo)')
          .eq('periodos.activo', true);
      return HorarioMateria.deMaterias(filas.map(Materia.fromMap).toList());
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<Actividad>> actividadesEntre(
    DateTime desde,
    DateTime hasta,
  ) async {
    try {
      final filas = await _db
          .from('actividades')
          .select(Actividad.selectPeriodoActivo)
          .eq('componentes_nota.materias.periodos.activo', true)
          .gte('fecha_limite', desde.toUtc().toIso8601String())
          .lt('fecha_limite', hasta.toUtc().toIso8601String())
          .order('fecha_limite');
      return filas.map(Actividad.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<BloqueEstudio>> bloquesEntre(
    DateTime desde,
    DateTime hasta,
  ) async {
    try {
      final filas = await _db
          .from('bloques_estudio')
          .select(BloqueEstudio.select)
          .inFilter('estado', [
            EstadoBloque.pendiente.db,
            EstadoBloque.completado.db,
          ])
          .gte('inicio', desde.toUtc().toIso8601String())
          .lt('inicio', hasta.toUtc().toIso8601String())
          .order('inicio');
      return filas.map(BloqueEstudio.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }
}
