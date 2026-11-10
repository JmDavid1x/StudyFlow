import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/assistant/domain/assistant_repository.dart';
import 'package:studyflow/features/assistant/domain/orden_respaldo.dart';
import 'package:studyflow/features/assistant/domain/programar_bloques.dart';

/// [AssistantRepository] con Supabase. No filtra por usuario: RLS ya
/// devuelve solo las filas de quien tiene la sesión.
class AssistantRepositoryImpl implements AssistantRepository {
  AssistantRepositoryImpl(this._db);

  final SupabaseClient _db;

  /// Cuántos mensajes se cargan al abrir el chat.
  static const _mensajesVisibles = 50;

  static String _utc(DateTime fecha) => fecha.toUtc().toIso8601String();

  @override
  Future<List<MensajeAsistente>> historial() async {
    try {
      final filas = await _db
          .from('mensajes_asistente')
          .select()
          .order('creado_en', ascending: false)
          .limit(_mensajesVisibles);
      return filas.map(MensajeAsistente.fromMap).toList().reversed.toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<MensajeAsistente> enviarMensaje({
    required RolMensaje rol,
    required String contenido,
    bool usadoRespaldo = false,
  }) async {
    try {
      final fila = await _db
          .from('mensajes_asistente')
          .insert({
            'perfil_id': _db.usuarioId,
            'rol': rol.db,
            'contenido': contenido,
            'usado_respaldo': usadoRespaldo,
          })
          .select()
          .single();
      return MensajeAsistente.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<String> responderConIA(
    String pregunta,
    List<Actividad> pendientes,
  ) async {
    // TODO(sprint-3): llamar al servicio de IA (Edge Function) con la pregunta
    // y las actividades pendientes. Mientras tanto se usa el orden de respaldo.
    throw const IaNoDisponible();
  }

  @override
  Future<List<Actividad>> actividadesPendientes() async {
    try {
      final filas = await _db
          .from('actividades')
          .select(Actividad.selectPeriodoActivo)
          .eq('componentes_nota.materias.periodos.activo', true)
          .order('fecha_limite', ascending: true);
      return filas
          .map(Actividad.fromMap)
          .where((a) => !a.estado.estaCerrada)
          .toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<HorarioClase>> horariosDeClase() async {
    try {
      final filas = await _db
          .from('horarios_clase')
          .select('*, materias!inner(periodos!inner(activo))')
          .eq('materias.periodos.activo', true);
      return filas.map(HorarioClase.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<BloqueEstudio>> bloquesPendientesDesde(DateTime desde) async {
    try {
      final filas = await _db
          .from('bloques_estudio')
          .select()
          .eq('estado', EstadoBloque.pendiente.db)
          .gt('fin', _utc(desde))
          .order('inicio', ascending: true);
      return filas.map(BloqueEstudio.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<PlanEstudio?> planActivo() async {
    try {
      final fila = await _db
          .from('planes_estudio')
          .select(PlanEstudio.select)
          .eq('activo', true)
          .maybeSingle();
      return fila == null ? null : PlanEstudio.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<PlanEstudio> crearPlan({
    required String resumen,
    required bool usadoRespaldo,
    required List<ItemOrden> orden,
    required List<BloquePlaneado> bloques,
    String? mensajeId,
  }) async {
    try {
      // 1. El plan anterior deja de estar activo (solo puede haber uno) y sus
      //    bloques pendientes se cancelan.
      final anteriores = await _db
          .from('planes_estudio')
          .update({'activo': false})
          .eq('activo', true)
          .select('id');
      final idsAnteriores = [
        for (final fila in anteriores) fila['id'] as String,
      ];
      if (idsAnteriores.isNotEmpty) {
        await _db
            .from('bloques_estudio')
            .update({'estado': EstadoBloque.cancelado.db})
            .inFilter('plan_id', idsAnteriores)
            .eq('estado', EstadoBloque.pendiente.db);
      }

      // 2. El plan nuevo.
      final plan = PlanEstudio(
        id: '',
        perfilId: _db.usuarioId,
        mensajeId: mensajeId,
        tipo: TipoPlan.solicitado,
        resumen: resumen,
        usadoRespaldo: usadoRespaldo,
        activo: true,
        creadoEn: DateTime.now(),
      );
      final filaPlan = await _db
          .from('planes_estudio')
          .insert(plan.toInsert())
          .select('id')
          .single();
      final planId = filaPlan['id'] as String;

      // 3. Sus actividades en orden. Tienen que ir antes que los bloques: la
      //    llave (plan_id, actividad_id) de cada bloque apunta a esta tabla.
      if (orden.isNotEmpty) {
        await _db.from('plan_actividades').insert([
          for (final item in orden)
            PlanActividad(
              planId: planId,
              actividadId: item.actividad.id,
              orden: item.orden,
              motivo: item.motivo,
              horasSugeridas: item.horasSugeridas,
            ).toInsert(),
        ]);
      }

      // 4. Los bloques del asistente.
      if (bloques.isNotEmpty) {
        await _db.from('bloques_estudio').insert([
          for (final bloque in bloques)
            BloqueEstudio(
              id: '',
              actividadId: bloque.actividadId,
              planId: planId,
              inicio: bloque.inicio,
              fin: bloque.fin,
              estado: EstadoBloque.pendiente,
              avisoMin: 15,
            ).toInsert(),
        ]);
      }

      final creado = await _db
          .from('planes_estudio')
          .select(PlanEstudio.select)
          .eq('id', planId)
          .single();
      return PlanEstudio.fromMap(creado);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }
}
