import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subscription/domain/planes_plus.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';

/// [SubscriptionRepository] con Supabase.
///
/// suscripciones y pagos son de solo lectura para la app: la prueba se pide
/// con el RPC `iniciar_prueba`, que crea la suscripción en_prueba y el pago
/// pendiente con una referencia SIM-… en la base. Nunca se mandan datos de
/// tarjeta: solo el método elegido.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._db);

  final SupabaseClient _db;

  @override
  Future<Suscripcion?> suscripcionVigente() async {
    try {
      final fila = await _db.from('suscripciones').select().inFilter('estado', [
        EstadoSuscripcion.enPrueba.db,
        EstadoSuscripcion.activa.db,
      ]).maybeSingle();
      return fila == null ? null : Suscripcion.fromMap(fila);
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }

  @override
  Future<Suscripcion> iniciarPrueba(
    Periodicidad periodicidad,
    MetodoPago metodo,
  ) async {
    try {
      final fila = await _db.rpc<Map<String, dynamic>>(
        'iniciar_prueba',
        params: {'p_periodicidad': periodicidad.db, 'p_metodo': metodo.db},
      );
      return Suscripcion.fromMap(fila);
    } on PostgrestException catch (e) {
      // 23505: el índice un_una_prueba no deja una segunda prueba por perfil.
      if (e.code == '23505') throw const AppException(mensajePruebaUsada);
      throw AppException(mensajeDeError(e));
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }
}
