// Los enums de la base de datos. Cada valor guarda su texto exacto en
// Supabase (`db`), porque allá van en snake_case (por_hacer) y en Dart en
// camelCase (porHacer).

enum TipoActividad {
  tarea('tarea'),
  proyecto('proyecto'),
  examen('examen');

  const TipoActividad(this.db);
  final String db;
  static TipoActividad fromDb(String value) => values.firstWhere((e) => e.db == value);
}

enum EstadoActividad {
  porHacer('por_hacer'),
  enProgreso('en_progreso'),
  completada('completada'),
  vencida('vencida'),
  noEntregada('no_entregada'),
  // Solo para exámenes:
  pendiente('pendiente'),
  presentado('presentado');

  const EstadoActividad(this.db);
  final String db;
  static EstadoActividad fromDb(String value) => values.firstWhere((e) => e.db == value);

  /// Completada, no entregada o presentado: ya no hay nada que hacer.
  bool get estaCerrada => this == completada || this == noEntregada || this == presentado;
}

enum CanalEntrega {
  intu('intu'),
  correo('correo'),
  enClase('en_clase'),
  whatsapp('whatsapp');

  const CanalEntrega(this.db);
  final String db;
  static CanalEntrega fromDb(String value) => values.firstWhere((e) => e.db == value);
}

enum Prioridad {
  baja('baja'),
  media('media'),
  alta('alta');

  const Prioridad(this.db);
  final String db;
  static Prioridad fromDb(String value) => values.firstWhere((e) => e.db == value);
}

enum EstadoBloque {
  pendiente('pendiente'),
  completado('completado'),
  descartado('descartado'),
  cancelado('cancelado');

  const EstadoBloque(this.db);
  final String db;
  static EstadoBloque fromDb(String value) => values.firstWhere((e) => e.db == value);
}

enum RolMensaje {
  usuario('usuario'),
  asistente('asistente');

  const RolMensaje(this.db);
  final String db;
  static RolMensaje fromDb(String value) => values.firstWhere((e) => e.db == value);
}

enum TipoPlan {
  diario('diario'),
  solicitado('solicitado');

  const TipoPlan(this.db);
  final String db;
  static TipoPlan fromDb(String value) => values.firstWhere((e) => e.db == value);
}

enum TipoNotificacion {
  entregaManana('entrega_manana'),
  entregaHoy('entrega_hoy'),
  tareaVencida('tarea_vencida'),
  tareaCompletada('tarea_completada'),
  bloquePorEmpezar('bloque_por_empezar'),
  bloquePendiente('bloque_pendiente'),
  planDelDia('plan_del_dia'),
  resumenSemanal('resumen_semanal');

  const TipoNotificacion(this.db);
  final String db;
  static TipoNotificacion fromDb(String value) => values.firstWhere((e) => e.db == value);
}

enum Periodicidad {
  mensual('mensual'),
  semestral('semestral');

  const Periodicidad(this.db);
  final String db;
  static Periodicidad fromDb(String value) => values.firstWhere((e) => e.db == value);
}

enum EstadoSuscripcion {
  enPrueba('en_prueba'),
  activa('activa'),
  cancelada('cancelada'),
  vencida('vencida');

  const EstadoSuscripcion(this.db);
  final String db;
  static EstadoSuscripcion fromDb(String value) => values.firstWhere((e) => e.db == value);
}

enum MetodoPago {
  tarjeta('tarjeta'),
  pse('pse'),
  nequi('nequi');

  const MetodoPago(this.db);
  final String db;
  static MetodoPago fromDb(String value) => values.firstWhere((e) => e.db == value);
}

enum EstadoPago {
  pendiente('pendiente'),
  aprobado('aprobado'),
  rechazado('rechazado'),
  reembolsado('reembolsado');

  const EstadoPago(this.db);
  final String db;
  static EstadoPago fromDb(String value) => values.firstWhere((e) => e.db == value);
}
