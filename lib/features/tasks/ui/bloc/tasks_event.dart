part of 'tasks_bloc.dart';

/// Lo que la pestaña Tareas le pide al [TasksBloc].
sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar (o recargar al volver de otra pantalla) las actividades.
final class TareasPedidas extends TasksEvent {
  const TareasPedidas();
}

/// Se tocó un chip de arriba.
final class FiltroCambiado extends TasksEvent {
  const FiltroCambiado(this.filtro);

  final FiltroTareas filtro;

  @override
  List<Object?> get props => [filtro];
}

/// Se tocó el círculo de una fila pendiente.
final class CirculoTocado extends TasksEvent {
  const CirculoTocado(this.actividad);

  final Actividad actividad;

  @override
  List<Object?> get props => [actividad];
}
