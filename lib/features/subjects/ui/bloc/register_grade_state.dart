import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';
import 'package:studyflow/features/subjects/domain/calculo_notas.dart';
import 'package:studyflow/features/subjects/domain/simular_nota.dart';

sealed class RegisterGradeState extends Equatable {
  const RegisterGradeState();

  @override
  List<Object?> get props => [];
}

class RegisterGradeLoading extends RegisterGradeState {
  const RegisterGradeLoading();
}

/// No hay a quién ponerle nota (sin materias o sin actividades).
class RegisterGradeEmpty extends RegisterGradeState {
  const RegisterGradeEmpty(this.mensaje);

  final String mensaje;

  @override
  List<Object?> get props => [mensaje];
}

class RegisterGradeError extends RegisterGradeState {
  const RegisterGradeError(this.mensaje);

  final String mensaje;

  @override
  List<Object?> get props => [mensaje];
}

/// Lo que cambió la nota que se acaba de guardar (para la hoja S3).
class NotaGuardada extends Equatable {
  const NotaGuardada({
    required this.materiaNombre,
    required this.antes,
    required this.despues,
  });

  final String materiaNombre;
  final double? antes;
  final double? despues;

  @override
  List<Object?> get props => [materiaNombre, antes, despues];
}

class RegisterGradeReady extends RegisterGradeState {
  const RegisterGradeReady({
    required this.materia,
    required this.actividades,
    required this.componenteId,
    required this.actividadId,
    required this.decimas,
    this.guardando = false,
    this.errorAlGuardar,
    this.guardada,
  });

  final Materia materia;
  final List<ActividadConNota> actividades;
  final String componenteId;
  final String? actividadId;

  /// Nota en décimas (46 = 4.6).
  final int decimas;
  final bool guardando;
  final String? errorAlGuardar;
  final NotaGuardada? guardada;

  double get nota => decimas / 10;

  List<ComponenteNota> get componentes => materia.componentes;

  /// Actividades del componente elegido.
  List<ActividadConNota> get visibles => actividades
      .where((a) => a.actividad.componenteId == componenteId)
      .toList();

  ActividadConNota? get actual {
    for (final a in actividades) {
      if (a.actividad.id == actividadId) return a;
    }
    return null;
  }

  bool get puedeGuardar => actual != null && !guardando;

  ResumenNotas get antes =>
      ResumenNotas.desde(meta: materia.metaNota, notas: actividades.ponderadas);

  ResumenNotas? get despues => actual == null
      ? null
      : resumenConNota(
          meta: materia.metaNota,
          actividades: actividades,
          actividadId: actual!.actividad.id,
          nota: nota,
        );

  RegisterGradeReady copyWith({
    List<ActividadConNota>? actividades,
    String? componenteId,
    String? actividadId,
    bool sinActividad = false,
    int? decimas,
    bool? guardando,
    String? errorAlGuardar,
    bool sinError = false,
    NotaGuardada? guardada,
  }) => RegisterGradeReady(
    materia: materia,
    actividades: actividades ?? this.actividades,
    componenteId: componenteId ?? this.componenteId,
    actividadId: sinActividad ? null : actividadId ?? this.actividadId,
    decimas: decimas ?? this.decimas,
    guardando: guardando ?? this.guardando,
    errorAlGuardar: sinError ? null : errorAlGuardar ?? this.errorAlGuardar,
    guardada: guardada ?? this.guardada,
  );

  @override
  List<Object?> get props => [
    materia,
    actividades,
    componenteId,
    actividadId,
    decimas,
    guardando,
    errorAlGuardar,
    guardada,
  ];
}
