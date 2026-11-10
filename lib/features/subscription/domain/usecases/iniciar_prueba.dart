import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';

/// "Iniciar prueba gratis" (Figma 32): si ya es Plus no hace nada nuevo; si
/// no, pide la prueba. Si ya la usó antes, el repositorio lanza el mensaje.
class IniciarPrueba {
  const IniciarPrueba(this._repositorio);

  final SubscriptionRepository _repositorio;

  Future<Suscripcion> call(Periodicidad periodicidad, MetodoPago metodo) async {
    final vigente = await _repositorio.suscripcionVigente();
    if (vigente != null) throw const AppException('Ya tienes StudyFlow Plus.');
    return _repositorio.iniciarPrueba(periodicidad, metodo);
  }
}
