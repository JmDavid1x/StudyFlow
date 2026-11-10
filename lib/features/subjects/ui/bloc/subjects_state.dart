import 'package:equatable/equatable.dart';

import 'package:studyflow/features/subjects/domain/resumen_semestre.dart';

sealed class SubjectsState extends Equatable {
  const SubjectsState();

  @override
  List<Object?> get props => [];
}

class SubjectsLoading extends SubjectsState {
  const SubjectsLoading();
}

/// El periodo no tiene materias: "Aún no tienes materias".
class SubjectsEmpty extends SubjectsState {
  const SubjectsEmpty();
}

class SubjectsLoaded extends SubjectsState {
  const SubjectsLoaded(this.resumen);

  final ResumenSemestre resumen;

  @override
  List<Object?> get props => [resumen];
}

class SubjectsError extends SubjectsState {
  const SubjectsError(this.mensaje);

  final String mensaje;

  @override
  List<Object?> get props => [mensaje];
}
