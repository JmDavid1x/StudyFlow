import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/study_blocks/domain/study_blocks_repository.dart';

/// [StudyBlocksRepository] con Supabase. No filtra por usuario: RLS ya
/// devuelve solo las filas de quien tiene la sesión.
class StudyBlocksRepositoryImpl implements StudyBlocksRepository {
  StudyBlocksRepositoryImpl(this._db);

  final SupabaseClient _db;

  @override
  Future<BloqueEstudio> crearBloque(BloqueEstudio bloque) async {
    try {
      final fila = await _db
          .from('bloques_estudio')
          .insert(bloque.toInsert())
          .select(BloqueEstudio.select)
          .single();
      return BloqueEstudio.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<void> completarBloque(String id) => _actualizar(id, {
    'estado': EstadoBloque.completado.db,
    'completado_en': DateTime.now().toUtc().toIso8601String(),
  });

  @override
  Future<void> reprogramarBloque(String id, DateTime inicio, DateTime fin) =>
      _actualizar(id, {
        'inicio': inicio.toUtc().toIso8601String(),
        'fin': fin.toUtc().toIso8601String(),
        'estado': EstadoBloque.pendiente.db,
      });

  @override
  Future<void> descartarBloque(String id) =>
      _actualizar(id, {'estado': EstadoBloque.descartado.db});

  Future<void> _actualizar(String id, Map<String, dynamic> cambios) async {
    try {
      await _db.from('bloques_estudio').update(cambios).eq('id', id);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<BloqueEstudio>> bloquesDeLaActividad(String actividadId) async {
    try {
      final filas = await _db
          .from('bloques_estudio')
          .select(BloqueEstudio.select)
          .eq('actividad_id', actividadId)
          .order('inicio');
      return filas.map(BloqueEstudio.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<EstadoActividad> estadoDeActividad(String actividadId) async {
    try {
      final fila = await _db
          .from('actividades')
          .select('estado')
          .eq('id', actividadId)
          .single();
      return EstadoActividad.fromDb(fila['estado'] as String);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<void> marcarActividadEnProgreso(String actividadId) async {
    try {
      // El filtro por estado evita pisar una actividad que alguien cerró mientras tanto.
      await _db
          .from('actividades')
          .update({'estado': EstadoActividad.enProgreso.db})
          .eq('id', actividadId)
          .eq('estado', EstadoActividad.porHacer.db);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<Actividad> actividad(String id) async {
    try {
      final fila = await _db
          .from('actividades')
          .select(Actividad.select)
          .eq('id', id)
          .single();
      return Actividad.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<Actividad>> actividadesAbiertas() async {
    try {
      final filas = await _db
          .from('actividades')
          .select(Actividad.selectPeriodoActivo)
          .eq('componentes_nota.materias.periodos.activo', true)
          .order('fecha_limite');
      return filas
          .map(Actividad.fromMap)
          .where((a) => !a.estado.estaCerrada)
          .toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }
}
