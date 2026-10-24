import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/demo_agenda.dart';

/// Una fila de la agenda del día (Figma 20): la hora a la izquierda y la
/// tarjeta de la clase, el bloque, la entrega o el examen a la derecha.
class AgendaItemTile extends StatelessWidget {
  const AgendaItemTile({super.key, required this.item, this.onTap});

  static const _timeWidth = 62.0;

  final AgendaItem item;
  final VoidCallback? onTap;

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
              sfFormatTime(item.start),
              style: SfTypography.caption.copyWith(color: SfColors.textSecondary),
            ),
          ),
        ),
        Expanded(
          child: item.kind == AgendaKind.classSession
              ? _ClassCard(item: item)
              : _ActivityCard(item: item, onTap: onTap),
        ),
      ],
    );
  }
}

/// Las clases van sin relleno, con el ícono del color de su materia: son
/// contexto del día, no algo por hacer.
class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.item});

  final AgendaItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.md, vertical: SfSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SfRadius.md),
        border: Border.all(color: SfColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_outlined, size: 20, color: item.subject.color),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Clase · ${item.subject.name}', style: SfTypography.body),
                Text(
                  '${item.detail} · ${formatTimeRange(item.start, item.end)}',
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
  const _ActivityCard({required this.item, this.onTap});

  final AgendaItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isBlock = item.kind == AgendaKind.studyBlock;
    // Los bloques van en SfColors.info; entregas y exámenes, con el color
    // de su materia.
    final (IconData labelIcon, String label, Color color) = switch (item.kind) {
      AgendaKind.studyBlock => (Icons.schedule, 'Bloque de estudio', SfColors.info),
      AgendaKind.exam => (Icons.flag_outlined, 'Examen', item.subject.color),
      _ => (Icons.flag_outlined, 'Entrega', item.subject.color),
    };
    final subtitle = isBlock
        ? '${item.subject.name} · ${formatTimeRange(item.start, item.end)}'
        : '${item.subject.name} · ${item.detail}';

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
                                Icon(labelIcon, size: 14, color: color),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    label,
                                    overflow: TextOverflow.ellipsis,
                                    style: SfTypography.caption.copyWith(color: color),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(item.title, style: SfTypography.bodyStrong),
                            Text(subtitle, style: SfTypography.caption),
                          ],
                        ),
                      ),
                      if (isBlock) ...[
                        const SizedBox(width: SfSpacing.xs),
                        SfCheckCircle(checked: item.done, color: color, onTap: onTap),
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
