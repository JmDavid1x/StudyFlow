import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';

enum TaskFormStatus { cargando, listo, error }

/// Estado del formulario de tarea (Figma 14 y 19).
class TaskFormState extends Equatable {
  const TaskFormState({
    this.status = TaskFormStatus.cargando,
    this.materias = const [],
    this.asignados = const [],
    this.errorCarga,
    this.guardando = false,
    this.errorGuardar,
    this.guardada,
  });

  final TaskFormStatus status;

  /// Materias del periodo activo con sus partes de la nota.
  final List<Materia> materias;

  /// Lo que ya usan las actividades de cada componente.
  final List<PorcentajeAsignado> asignados;

  /// Por qué no se pudieron cargar las materias (status = error).
  final String? errorCarga;

  /// true mientras se guarda en Supabase.
  final bool guardando;

  /// Por qué no se pudo guardar (se muestra abajo, sin perder lo escrito).
  final String? errorGuardar;

  /// La actividad ya guardada: la pantalla navega cuando llega.
  final Actividad? guardada;

  TaskFormState copyWith({
    TaskFormStatus? status,
    List<Materia>? materias,
    List<PorcentajeAsignado>? asignados,
    String? errorCarga,
    bool? guardando,
    String? errorGuardar,
    Actividad? guardada,
  }) => TaskFormState(
    status: status ?? this.status,
    materias: materias ?? this.materias,
    asignados: asignados ?? this.asignados,
    errorCarga: errorCarga,
    guardando: guardando ?? this.guardando,
    errorGuardar: errorGuardar,
    guardada: guardada ?? this.guardada,
  );

  @override
  List<Object?> get props => [
    status,
    materias,
    asignados,
    errorCarga,
    guardando,
    errorGuardar,
    guardada,
  ];
}
