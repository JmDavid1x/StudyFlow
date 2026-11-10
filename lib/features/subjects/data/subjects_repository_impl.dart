import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';
import 'package:studyflow/features/subjects/domain/subjects_repository.dart';

class SubjectsRepositoryImpl implements SubjectsRepository {
  SubjectsRepositoryImpl(this._db);

  final SupabaseClient _db;

  /// Actividades con su calificación y su materia (el componente es `!inner`
  /// para poder filtrar por `componentes_nota.materia_id`).
  static const _selectActividadConNota =
      '*, calificaciones(*), componentes_nota!inner(id, nombre, materia_id, materias(id, nombre, color))';

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
  Future<Periodo> crearPeriodo({
    required String nombre,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    double? metaPromedio,
  }) async {
    try {
      final fila = await _db
          .from('periodos')
          .insert({
            'perfil_id': _db.usuarioId,
            'nombre': nombre,
            'fecha_inicio': diaDb(fechaInicio),
            'fecha_fin': diaDb(fechaFin),
            'meta_promedio': metaPromedio,
            'activo': true,
          })
          .select()
          .single();
      return Periodo.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<Materia>> materiasDelPeriodo() async {
    try {
      final periodo = await periodoActivo();
      if (periodo == null) return const [];
      final filas = await _db
          .from('materias')
          .select(Materia.select)
          .eq('periodo_id', periodo.id)
          .order('nombre');
      return filas.map(Materia.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<Materia> crearMateria(
    Materia materia,
    List<HorarioClase> horarios,
    List<ComponenteNota> componentes,
  ) async {
    String? materiaId;
    try {
      final creada = await _db
          .from('materias')
          .insert(materia.toInsert())
          .select()
          .single();
      final id = materiaId = creada['id'] as String;

      if (horarios.isNotEmpty) {
        await _db.from('horarios_clase').insert([
          for (final h in horarios) {...h.toInsert(), 'materia_id': id},
        ]);
      }
      if (componentes.isNotEmpty) {
        await _db.from('componentes_nota').insert([
          for (final c in componentes) {...c.toInsert(), 'materia_id': id},
        ]);
      }

      final completa = await _db
          .from('materias')
          .select(Materia.select)
          .eq('id', id)
          .single();
      return Materia.fromMap(completa);
    } catch (e) {
      // Si algo falló a la mitad, no dejamos la materia a medias (cascade borra el resto).
      if (materiaId != null) {
        try {
          await _db.from('materias').delete().eq('id', materiaId);
        } catch (_) {}
      }
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<List<ActividadConNota>> actividadesConNota(String materiaId) async {
    try {
      final filas = await _db
          .from('actividades')
          .select(_selectActividadConNota)
          .eq('componentes_nota.materia_id', materiaId)
          .order('fecha_limite');
      return filas.map((fila) {
        final calificacion = _calificacionDe(fila['calificaciones']);
        return ActividadConNota(
          actividad: Actividad.fromMap(fila),
          calificacion: calificacion,
        );
      }).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<void> registrarNota(String actividadId, double nota) async {
    try {
      await _db.from('calificaciones').upsert({
        'actividad_id': actividadId,
        'nota': nota,
      }, onConflict: 'actividad_id');
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<void> terminarConfiguracion({required bool pushActivas}) async {
    try {
      final usuarioId = _db.usuarioId;
      await _db
          .from('perfiles')
          .update({'configuracion_completa': true})
          .eq('id', usuarioId);
      await _db
          .from('ajustes_notificacion')
          .update({'push_activas': pushActivas})
          .eq('perfil_id', usuarioId);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  /// `calificaciones` es única por actividad: PostgREST la devuelve como un
  /// objeto (o null), pero por si llega como lista tomamos la primera.
  Calificacion? _calificacionDe(Object? valor) {
    final mapa = anidado(valor);
    if (mapa != null) return Calificacion.fromMap(mapa);
    final filas = lista(valor);
    return filas.isEmpty ? null : Calificacion.fromMap(filas.first);
  }
}
