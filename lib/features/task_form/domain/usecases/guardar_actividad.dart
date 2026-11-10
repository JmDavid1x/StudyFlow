import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';

/// Crea o edita una tarea, proyecto o examen con las reglas de la base:
/// - tarea y proyecto: estado por_hacer al crearse y con canal de entrega;
/// - examen: estado pendiente al crearse, sin canal y con lugar opcional;
/// - porcentaje entre 0 y 100, y título obligatorio.
class GuardarActividad {
  const GuardarActividad(this._repositorio);

  final TaskFormRepository _repositorio;

  /// Ajusta la actividad a las reglas antes de guardarla. Si es nueva le pone
  /// el estado inicial; si cambió de tipo, le pone el estado que le toca.
  static Actividad preparar(Actividad actividad, {required bool esNueva}) {
    final titulo = actividad.titulo.trim();
    if (titulo.isEmpty) throw const AppException('Escribe el título.');
    if (actividad.porcentaje < 0 || actividad.porcentaje > 100) {
      throw const AppException('El porcentaje debe estar entre 0 y 100.');
    }

    if (actividad.esExamen) {
      final estado = esNueva || !_esDeExamen(actividad.estado)
          ? EstadoActividad.pendiente
          : actividad.estado;
      final lugar = actividad.lugar?.trim();
      return _conCanal(
        actividad.copyWith(titulo: titulo, estado: estado),
        null,
        lugar: (lugar == null || lugar.isEmpty) ? null : lugar,
      );
    }

    if (actividad.canalEntrega == null) {
      throw const AppException('Elige dónde se entrega.');
    }
    final estado = esNueva || _esDeExamen(actividad.estado)
        ? EstadoActividad.porHacer
        : actividad.estado;
    return _conCanal(
      actividad.copyWith(titulo: titulo, estado: estado),
      actividad.canalEntrega,
      lugar: null,
    );
  }

  Future<Actividad> crear(Actividad actividad) =>
      _repositorio.crearActividad(preparar(actividad, esNueva: true));

  Future<Actividad> editar(Actividad actividad) =>
      _repositorio.editarActividad(preparar(actividad, esNueva: false));

  static bool _esDeExamen(EstadoActividad estado) =>
      estado == EstadoActividad.pendiente ||
      estado == EstadoActividad.presentado;

  /// copyWith no deja poner canal o lugar en nulo, así que se arma de nuevo.
  static Actividad _conCanal(
    Actividad a,
    CanalEntrega? canal, {
    required String? lugar,
  }) => Actividad(
    id: a.id,
    componenteId: a.componenteId,
    titulo: a.titulo,
    tipo: a.tipo,
    fechaLimite: a.fechaLimite,
    porcentaje: a.porcentaje,
    prioridad: a.prioridad,
    estado: a.estado,
    recordatorio: a.recordatorio,
    creadoEn: a.creadoEn,
    actualizadoEn: a.actualizadoEn,
    canalEntrega: canal,
    lugar: lugar,
    notas: (a.notas == null || a.notas!.trim().isEmpty)
        ? null
        : a.notas!.trim(),
    completadaEn: a.completadaEn,
    componenteNombre: a.componenteNombre,
    materiaId: a.materiaId,
    materiaNombre: a.materiaNombre,
    materiaColorHex: a.materiaColorHex,
  );
}
