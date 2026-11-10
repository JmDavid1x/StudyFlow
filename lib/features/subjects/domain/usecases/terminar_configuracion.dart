import 'package:studyflow/features/subjects/domain/subjects_repository.dart';

/// Último paso de la configuración inicial: marca el perfil como configurado
/// y guarda si el estudiante activó los recordatorios.
class TerminarConfiguracion {
  const TerminarConfiguracion(this._repositorio);

  final SubjectsRepository _repositorio;

  Future<void> call({required bool pushActivas}) =>
      _repositorio.terminarConfiguracion(pushActivas: pushActivas);
}
