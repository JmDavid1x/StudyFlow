import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';

/// [TaskFormRepository] con Supabase. No filtra por usuario: RLS ya devuelve
/// solo las filas de quien tiene la sesión.
class TaskFormRepositoryImpl implements TaskFormRepository {
  TaskFormRepositoryImpl(this._db);

  final SupabaseClient _db;

  @override
  Future<List<Materia>> materiasConComponentes() async {
    try {
      final filas = await _db
          .from('materias')
          .select('${Materia.select}, periodos!inner(activo)')
          .eq('periodos.activo', true)
          .order('nombre');
      return filas.map(Materia.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<PorcentajeAsignado>> porcentajesAsignados() async {
    try {
      final filas = await _db
          .from('actividades')
          .select(
            'id, componente_id, porcentaje, componentes_nota!inner(materias!inner(periodos!inner(activo)))',
          )
          .eq('componentes_nota.materias.periodos.activo', true);
      return [
        for (final fila in filas)
          (
            actividadId: fila['id'] as String,
            componenteId: fila['componente_id'] as String,
            porcentaje: numero(fila['porcentaje']),
          ),
      ];
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<Actividad> crearActividad(Actividad actividad) async {
    try {
      final fila = await _db
          .from('actividades')
          .insert(actividad.toInsert())
          .select(Actividad.select)
          .single();
      return Actividad.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<Actividad> editarActividad(Actividad actividad) async {
    try {
      final fila = await _db
          .from('actividades')
          .update(actividad.toInsert())
          .eq('id', actividad.id)
          .select(Actividad.select)
          .single();
      return Actividad.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }
}
