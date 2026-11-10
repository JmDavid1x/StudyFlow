import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/tasks/domain/tasks_repository.dart';

/// [TasksRepository] con Supabase. No filtra por usuario: RLS ya devuelve
/// solo las filas de quien tiene la sesión.
class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl(this._db);

  final SupabaseClient _db;

  String get _ahora => DateTime.now().toUtc().toIso8601String();

  @override
  Future<List<Actividad>> actividadesDelPeriodo() async {
    try {
      final filas = await _db
          .from('actividades')
          .select(Actividad.selectPeriodoActivo)
          .eq('componentes_nota.materias.periodos.activo', true)
          .order('fecha_limite');
      return filas.map(Actividad.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<Actividad?> actividadPorId(String id) async {
    try {
      final fila = await _db.from('actividades').select(Actividad.select).eq('id', id).maybeSingle();
      return fila == null ? null : Actividad.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<void> completar(String id) async {
    try {
      await _db
          .from('actividades')
          .update({'estado': EstadoActividad.completada.db, 'completada_en': _ahora})
          .eq('id', id);
      await _db
          .from('bloques_estudio')
          .update({'estado': EstadoBloque.cancelado.db})
          .eq('actividad_id', id)
          .eq('estado', EstadoBloque.pendiente.db);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<void> marcarNoEntregada(String id) => _cambiarEstado(id, EstadoActividad.noEntregada);

  @override
  Future<void> marcarPresentado(String id) => _cambiarEstado(id, EstadoActividad.presentado);

  Future<void> _cambiarEstado(String id, EstadoActividad estado) async {
    try {
      await _db.from('actividades').update({'estado': estado.db}).eq('id', id);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<void> eliminar(String id) async {
    try {
      await _db.from('actividades').delete().eq('id', id);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<BloqueEstudio>> bloquesDeActividad(String id) async {
    try {
      final filas = await _db.from('bloques_estudio').select().eq('actividad_id', id).order('inicio');
      return filas.map(BloqueEstudio.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }
}
