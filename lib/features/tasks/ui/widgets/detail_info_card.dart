import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Una fila de [DetailInfoCard]: "Entrega · Mié 23/09 · 11:59 p. m.".
class DetailRow {
  const DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.note,
    this.noteColor = SfColors.warning,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Texto pequeño debajo del valor: "Faltan 2 días".
  final String? note;
  final Color noteColor;
}

/// Tarjeta con los datos de una actividad, uno por fila (Figma 18 y 29).
class DetailInfoCard extends StatelessWidget {
  const DetailInfoCard({super.key, required this.rows});

  final List<DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: SfColors.border),
            _Row(row: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});

  final DetailRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.md, vertical: SfSpacing.sm),
      child: LayoutBuilder(builder: (context, constraints) => _content(constraints.maxWidth * 0.6)),
    );
  }

  Widget _content(double maxValueWidth) {
    return Row(
      children: [
        Container(
          width: SfSpacing.xl + SfSpacing.xxs,
          height: SfSpacing.xl + SfSpacing.xxs,
          decoration: BoxDecoration(
            color: SfColors.primarySoft,
            borderRadius: BorderRadius.circular(SfRadius.sm),
          ),
          child: Icon(row.icon, size: SfSpacing.lg - SfSpacing.xxs, color: SfColors.primaryLight),
        ),
        const SizedBox(width: SfSpacing.sm),
        Expanded(
          child: Text(row.label, style: SfTypography.body.copyWith(color: SfColors.textSecondary)),
        ),
        const SizedBox(width: SfSpacing.sm),
        // El valor cabe en una línea en un teléfono normal; en uno pequeño
        // baja de línea en lugar de esconder la etiqueta.
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxValueWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(row.value, textAlign: TextAlign.end, style: SfTypography.bodyStrong),
              if (row.note != null)
                Text(
                  row.note!,
                  textAlign: TextAlign.end,
                  style: SfTypography.caption.copyWith(color: row.noteColor, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
