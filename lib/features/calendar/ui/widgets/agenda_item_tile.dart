import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/calendar/domain/agenda_del_dia.dart';
import 'package:studyflow/features/calendar/ui/widgets/formato.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_data.dart';

/// Una fila de la agenda del día (Figma 20): la hora a la izquierda y la
/// tarjeta de la clase, el bloque, la entrega o el examen a la derecha.
class AgendaItemTile extends StatelessWidget {
  const AgendaItemTile({
    super.key,
    required this.entrada,
    this.onTap,
    this.onComplete,
  });

  static const _timeWidth = 62.0;

  final EntradaAgenda entrada;

  /// Toque en la tarjeta: abre el detalle.
  final VoidCallback? onTap;

  /// Toque en el circulito de un bloque: lo marca como completado.
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _timeWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: SfSpacing.sm),
            child: Text(
              horaDe(entrada.inicio),
              style: SfTypography.caption.copyWith(
                color: SfColors.textSecondary,
              ),
            ),
          ),
        ),
        Expanded(
          child: switch (entrada) {
            final ClaseEnAgenda clase => _ClassCard(clase: clase),
            _ => _ActivityCard(
              entrada: entrada,
              onTap: onTap,
              onComplete: onComplete,
            ),
          },
        ),
      ],
    );
  }
}

/// Las clases van sin relleno, con el ícono del color de su materia: son
/// contexto del día, no algo por hacer.
class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.clase});

  final ClaseEnAgenda clase;

  @override
  Widget build(BuildContext context) {
    final materia = clase.clase.materia;
    final lugar = clase.clase.horario.salon ?? materia.profesor;
    final rango = rangoHoras(clase.inicio, clase.fin);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SfSpacing.md,
        vertical: SfSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SfRadius.md),
        border: Border.all(color: SfColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_outlined, size: 20, color: materia.color),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Clase · ${materia.nombre}', style: SfTypography.body),
                Text(
                  lugar == null ? rango : '$lugar · $rango',
                  style: SfTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloque de estudio, entrega o examen: tarjeta con una barra de color a la
/// izquierda (SfColors.info en los bloques, el de la materia en lo demás).
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.entrada, this.onTap, this.onComplete});

  final EntradaAgenda entrada;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final (
      IconData icono,
      String etiqueta,
      Color color,
      String titulo,
      String detalle,
      BloqueEstudio? bloque,
    ) = switch (entrada) {
      BloqueEnAgenda(:final bloque) => (
        Icons.schedule,
        'Bloque de estudio',
        SfColors.info,
        bloque.actividadTitulo ?? 'Bloque de estudio',
        [
          ?bloque.materiaNombre,
          rangoHoras(bloque.inicio, bloque.fin),
        ].join(' · '),
        bloque,
      ),
      EntregaEnAgenda(:final actividad) => (
        Icons.flag_outlined,
        actividad.esExamen ? 'Examen' : 'Entrega',
        actividad.materiaColor ?? SfColors.primaryLight,
        actividad.titulo,
        [
          ?actividad.materiaNombre,
          actividad.esExamen ? actividad.lugar : actividad.canalEntrega?.texto,
        ].nonNulls.join(' · '),
        null,
      ),
      ClaseEnAgenda() => throw StateError('Las clases usan _ClassCard'),
    };
    final completado = bloque?.estado == EstadoBloque.completado;

    return Material(
      color: SfColors.surface,
      borderRadius: BorderRadius.circular(SfRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        // IntrinsicHeight deja que la barra de color mida lo mismo que el texto.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: SfSpacing.xxs, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(SfSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(icono, size: 14, color: color),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    etiqueta,
                                    overflow: TextOverflow.ellipsis,
                                    style: SfTypography.caption.copyWith(
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(titulo, style: SfTypography.bodyStrong),
                            if (detalle.isNotEmpty)
                              Text(detalle, style: SfTypography.caption),
                          ],
                        ),
                      ),
                      if (bloque != null) ...[
                        const SizedBox(width: SfSpacing.xs),
                        // Un bloque ya completado no se vuelve a completar.
                        SfCheckCircle(
                          checked: completado,
                          color: color,
                          onTap: completado ? null : onComplete,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
