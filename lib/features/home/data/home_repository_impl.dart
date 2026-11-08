import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/home/domain/home_repository.dart';

/// [HomeRepository] con Supabase. No filtra por usuario: RLS ya devuelve
/// solo las filas de quien tiene la sesión (por eso perfiles trae una sola).
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._db);

  final SupabaseClient _db;

  static String _utc(DateTime fecha) => fecha.toUtc().toIso8601String();

  @override
  Future<Perfil> perfil() async {
    try {
      final fila = await _db.from('perfiles').select(Perfil.select).single();
      return Perfil.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<Actividad>> actividadesEntre(DateTime desde, DateTime hasta) async {
    try {
      final filas = await _db
          .from('actividades')
          .select(Actividad.selectPeriodoActivo)
          .eq('componentes_nota.materias.periodos.activo', true)
          .gte('fecha_limite', _utc(desde))
          .lt('fecha_limite', _utc(hasta))
          .order('fecha_limite');
      return filas.map(Actividad.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<BloqueEstudio>> bloquesEntre(DateTime desde, DateTime hasta) async {
    try {
      final filas = await _db
          .from('bloques_estudio')
          .select(BloqueEstudio.select)
          .gte('inicio', _utc(desde))
          .lt('inicio', _utc(hasta))
          .order('inicio');
      return filas.map(BloqueEstudio.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<Notificacion>> notificaciones() async {
    try {
      final filas = await _db.from('notificaciones').select().order('programada_para', ascending: false);
      return filas.map(Notificacion.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<void> marcarLeida(String id) async {
    try {
      await _db.from('notificaciones').update({'leida_en': _utc(DateTime.now())}).eq('id', id);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<void> borrarNotificacion(String id) async {
    try {
      await _db.from('notificaciones').delete().eq('id', id);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }
}
