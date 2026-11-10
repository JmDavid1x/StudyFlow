import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';

/// Textos de los enums de la base para el formulario (Figma 14).
extension TipoActividadTexto on TipoActividad {
  String get texto => switch (this) {
    TipoActividad.tarea => 'Tarea',
    TipoActividad.examen => 'Examen',
    TipoActividad.proyecto => 'Proyecto',
  };
}

extension PrioridadTexto on Prioridad {
  String get texto => switch (this) {
    Prioridad.baja => 'Baja',
    Prioridad.media => 'Media',
    Prioridad.alta => 'Alta',
  };
}

/// Opciones de "¿Dónde se entrega?" con su texto e ícono.
extension CanalEntregaTexto on CanalEntrega {
  String get texto => switch (this) {
    CanalEntrega.intu => 'INTU',
    CanalEntrega.correo => 'Correo',
    CanalEntrega.enClase => 'En clase',
    CanalEntrega.whatsapp => 'WhatsApp',
  };

  String get subtitulo => switch (this) {
    CanalEntrega.intu => 'Plataforma de la U',
    CanalEntrega.correo => 'Por e-mail al profe',
    CanalEntrega.enClase => 'En persona',
    CanalEntrega.whatsapp => 'Al grupo o al profe',
  };

  IconData get icono => switch (this) {
    CanalEntrega.intu => Icons.school_outlined,
    CanalEntrega.correo => Icons.mail_outline,
    CanalEntrega.enClase => Icons.groups_outlined,
    CanalEntrega.whatsapp => Icons.chat_bubble_outline,
  };
}

/// Lo que el usuario llena en el formulario de tarea (Figma 14 y 19).
/// Con [toActividad] se convierte en la [Actividad] que se guarda en Supabase.
class TaskFormData {
  const TaskFormData({
    this.title = '',
    this.materia,
    this.componente,
    this.tipo = TipoActividad.tarea,
    this.date,
    this.time,
    this.porcentaje = 0,
    this.prioridad = Prioridad.media,
    this.canal,
    this.place = '',
    this.reminder = true,
    this.notes = '',
  });

  /// Carga una actividad guardada en el formulario (Editar tarea). La materia
  /// y el componente se buscan en [materias] por el componente de la actividad.
  factory TaskFormData.fromActividad(
    Actividad actividad,
    List<Materia> materias,
  ) {
    Materia? materia;
    ComponenteNota? componente;
    for (final m in materias) {
      for (final c in m.componentes) {
        if (c.id == actividad.componenteId) {
          materia = m;
          componente = c;
        }
      }
    }
    return TaskFormData(
      title: actividad.titulo,
      materia: materia,
      componente: componente,
      tipo: actividad.tipo,
      date: DateTime(
        actividad.fechaLimite.year,
        actividad.fechaLimite.month,
        actividad.fechaLimite.day,
      ),
      time: TimeOfDay.fromDateTime(actividad.fechaLimite),
      porcentaje: actividad.porcentaje.round(),
      prioridad: actividad.prioridad,
      canal: actividad.canalEntrega,
      place: actividad.lugar ?? '',
      reminder: actividad.recordatorio,
      notes: actividad.notas ?? '',
    );
  }

  /// Si no se elige hora, la entrega queda a las 11:59 p. m. de ese día.
  static const horaPorDefecto = TimeOfDay(hour: 23, minute: 59);

  final String title;
  final Materia? materia;

  /// Parte de la nota a la que suma (componente_id es obligatorio en la base).
  final ComponenteNota? componente;
  final TipoActividad tipo;
  final DateTime? date;
  final TimeOfDay? time;

  /// Porcentaje de la nota que vale esta actividad (15 = 15 %).
  final int porcentaje;
  final Prioridad prioridad;

  /// Canal de entrega. Solo aplica si no es examen.
  final CanalEntrega? canal;

  /// Lugar del examen. Solo aplica si es examen.
  final String place;
  final bool reminder;
  final String notes;

  /// La actividad para guardar. Con [original] (al editar) conserva su id,
  /// estado y fechas; si es nueva, el estado lo pone GuardarActividad.
  /// Solo se llama cuando ya hay componente y fecha (el formulario lo valida).
  Actividad toActividad({Actividad? original}) {
    final hora = time ?? horaPorDefecto;
    final ahora = DateTime.now();
    return Actividad(
      id: original?.id ?? '',
      componenteId: componente!.id,
      titulo: title,
      tipo: tipo,
      fechaLimite: DateTime(
        date!.year,
        date!.month,
        date!.day,
        hora.hour,
        hora.minute,
      ),
      porcentaje: porcentaje.toDouble(),
      prioridad: prioridad,
      estado: original?.estado ?? EstadoActividad.porHacer,
      recordatorio: reminder,
      creadoEn: original?.creadoEn ?? ahora,
      actualizadoEn: original?.actualizadoEn ?? ahora,
      canalEntrega: tipo == TipoActividad.examen ? null : canal,
      lugar: place,
      notas: notes,
      completadaEn: original?.completadaEn,
    );
  }
}
