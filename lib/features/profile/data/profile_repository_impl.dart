import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/assistant/domain/limite_consultas.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';

/// [ProfileRepository] con Supabase. No filtra por usuario: RLS ya devuelve
/// solo las filas de quien tiene la sesión (por eso perfiles trae una sola).
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._db);

  final SupabaseClient _db;

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
  Future<Perfil> actualizarPerfil({
    required String nombre,
    String? programa,
    int? semestre,
  }) async {
    try {
      final actual = await perfil();
      final cambiado = actual.copyWith(
        nombre: nombre.trim(),
        programa: programa,
        semestre: semestre,
      );
      final fila = await _db
          .from('perfiles')
          .update(cambiado.toUpdate())
          .eq('id', actual.id)
          .select(Perfil.select)
          .single();
      return Perfil.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<AjustesNotificacion> ajustes() async {
    try {
      final fila = await _db.from('ajustes_notificacion').select().single();
      return AjustesNotificacion.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<void> guardarAjustes(AjustesNotificacion ajustes) async {
    try {
      await _db
          .from('ajustes_notificacion')
          .update(ajustes.toUpdate())
          .eq('perfil_id', ajustes.perfilId);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<Periodo?> periodoActivo() async {
    try {
      final fila = await _db
          .from('periodos')
          .select()
          .eq('activo', true)
          .maybeSingle();
      return fila == null ? null : Periodo.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<int> consultasUsadasEstaSemana(DateTime ahora) async {
    try {
      // Trae las respuestas del asistente desde el lunes y la regla de qué
      // cuenta como consulta se aplica en Dart (limite_consultas.dart).
      final filas = await _db
          .from('mensajes_asistente')
          .select()
          .eq('rol', RolMensaje.asistente.db)
          .gte('creado_en', inicioDeSemana(ahora).toUtc().toIso8601String());
      return consultasUsadas(filas.map(MensajeAsistente.fromMap), ahora);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }
}
