import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/assistant/domain/limite_consultas.dart';
import 'package:studyflow/features/profile/domain/profile_repository.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';

/// Todo lo que muestra la pestaña Perfil.
class ResumenPerfil {
  const ResumenPerfil({
    required this.perfil,
    required this.limite,
    this.suscripcion,
    this.periodo,
  });

  final Perfil perfil;

  /// Plan actual: Plus si hay una suscripción vigente; si no, gratis.
  final Suscripcion? suscripcion;
  final LimiteConsultas limite;

  /// Semestre activo (para la meta), o null si aún no lo crea.
  final Periodo? periodo;

  bool get esPlus => suscripcion?.esVigente ?? false;
}

/// Junta el perfil, la suscripción, el semestre y las consultas de la semana.
class CargarPerfil {
  const CargarPerfil(this._perfiles, this._suscripciones);

  final ProfileRepository _perfiles;
  final SubscriptionRepository _suscripciones;

  Future<ResumenPerfil> call(DateTime ahora) async {
    // Las cuatro consultas van a la vez; si una falla, llega su error.
    final perfil = _perfiles.perfil();
    final suscripcion = _suscripciones.suscripcionVigente();
    final periodo = _perfiles.periodoActivo();
    final usadas = _perfiles.consultasUsadasEstaSemana(ahora);
    await Future.wait<Object?>([perfil, suscripcion, periodo, usadas]);
    final vigente = await suscripcion;
    return ResumenPerfil(
      perfil: await perfil,
      suscripcion: vigente,
      periodo: await periodo,
      limite: LimiteConsultas(
        usadas: await usadas,
        esPlus: vigente?.esVigente ?? false,
      ),
    );
  }
}
