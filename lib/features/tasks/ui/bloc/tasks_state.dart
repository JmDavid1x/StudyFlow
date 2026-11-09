part of 'tasks_bloc.dart';

/// En qué va la carga de la lista.
enum EstadoTareas { cargando, listo, vacio, error }

/// Una sección de la lista con su título.
class SeccionTareas extends Equatable {
  const SeccionTareas(this.titulo, this.actividades, {this.vencidas = false});

  final String titulo;
  final List<Actividad> actividades;

  /// Las vencidas se pintan en rojo y sin círculo (primero se pregunta si se entregó).
  final bool vencidas;

  @override
  List<Object?> get props => [titulo, actividades, vencidas];
}

const _sinTareas = TareasAgrupadas(vencidas: [], hoy: [], semana: [], masAdelante: [], completadas: []);

class TasksState extends Equatable {
  const TasksState({
    this.estado = EstadoTareas.cargando,
    this.filtro = FiltroTareas.todas,
    this.grupos = _sinTareas,
    this.ahora,
    this.mensaje,
    this.aviso,
    this.avisoId = 0,
  });

  final EstadoTareas estado;
  final FiltroTareas filtro;
  final TareasAgrupadas grupos;

  /// Hora con la que se agrupó (para que los textos "hoy", "mañana" coincidan).
  final DateTime? ahora;

  /// Error de la carga (estado error).
  final String? mensaje;

  /// Error de una acción, para mostrar en un SnackBar. [avisoId] cambia cada vez.
  final String? aviso;
  final int avisoId;

  /// Secciones que se ven con el chip elegido, sin las vacías. "Hoy" incluye
  /// las vencidas y "Esta semana" incluye las de hoy (como en Figma 17).
  List<SeccionTareas> get secciones {
    final f = filtro;
    final todas = f == FiltroTareas.todas;
    return [
      if (todas || f == FiltroTareas.hoy || f == FiltroTareas.vencidas)
        SeccionTareas('Vencidas', grupos.vencidas, vencidas: true),
      if (todas || f == FiltroTareas.hoy || f == FiltroTareas.semana) SeccionTareas('Hoy', grupos.hoy),
      if (todas || f == FiltroTareas.semana) SeccionTareas('Esta semana', grupos.semana),
      if (todas) SeccionTareas('Más adelante', grupos.masAdelante),
      if (todas || f == FiltroTareas.completadas) SeccionTareas('Completadas', grupos.completadas),
    ].where((seccion) => seccion.actividades.isNotEmpty).toList();
  }

  TasksState copyWith({
    EstadoTareas? estado,
    FiltroTareas? filtro,
    TareasAgrupadas? grupos,
    DateTime? ahora,
    String? mensaje,
    String? aviso,
    int? avisoId,
  }) => TasksState(
    estado: estado ?? this.estado,
    filtro: filtro ?? this.filtro,
    grupos: grupos ?? this.grupos,
    ahora: ahora ?? this.ahora,
    mensaje: mensaje ?? this.mensaje,
    aviso: aviso ?? this.aviso,
    avisoId: avisoId ?? this.avisoId,
  );

  @override
  List<Object?> get props => [
    estado,
    filtro,
    grupos.vencidas,
    grupos.hoy,
    grupos.semana,
    grupos.masAdelante,
    grupos.completadas,
    ahora,
    mensaje,
    aviso,
    avisoId,
  ];
}
