import 'package:equatable/equatable.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/features/subjects/domain/actividad_con_nota.dart';
import 'package:studyflow/features/subjects/domain/calculo_notas.dart';
import 'package:studyflow/features/subjects/domain/resumen_semestre.dart';

sealed class SubjectDetailState extends Equatable {
  const SubjectDetailState();

  @override
  List<Object?> get props => [];
}

class SubjectDetailLoading extends SubjectDetailState {
  const SubjectDetailLoading();
}

/// No hay materia que mostrar (por ejemplo, se abrió sin argumento y el periodo está vacío).
class SubjectDetailEmpty extends SubjectDetailState {
  const SubjectDetailEmpty();
}

class SubjectDetailLoaded extends SubjectDetailState {
  const SubjectDetailLoaded({
    required this.materia,
    required this.actividades,
    required this.resumen,
    required this.componentes,
  });

  final Materia materia;
  final List<ActividadConNota> actividades;
  final ResumenNotas resumen;
  final List<ResumenComponente> componentes;

  @override
  List<Object?> get props => [materia, actividades, resumen, componentes];
}

class SubjectDetailError extends SubjectDetailState {
  const SubjectDetailError(this.mensaje);

  final String mensaje;

  @override
  List<Object?> get props => [mensaje];
}
