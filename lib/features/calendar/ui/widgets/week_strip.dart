import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/calendar/ui/widgets/calendar_labels.dart';

/// Franja con los 7 días de la semana (Figma 20). Al tocar un día se elige;
/// los puntos muestran, con el color de su materia, lo que está pendiente.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.weekStart,
    required this.selected,
    required this.onSelect,
    required this.dotsFor,
  });

  /// Lunes de la semana que se muestra.
  final DateTime weekStart;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  /// Colores de los puntos de un día (uno por cada cosa pendiente).
  final List<Color> Function(DateTime day) dotsFor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: SfSpacing.xxs + 2),
          Expanded(
            child: _DayChip(
              day: weekStart.add(Duration(days: i)),
              selected: DateUtils.isSameDay(weekStart.add(Duration(days: i)), selected),
              dots: dotsFor(weekStart.add(Duration(days: i))),
              onTap: () => onSelect(weekStart.add(Duration(days: i))),
            ),
          ),
        ],
      ],
    );
  }
}

/// Un día de la franja: nombre corto, número y puntos de pendientes.
class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.dots,
    required this.onTap,
  });

  static const _dotSize = 5.0;

  /// Más de tres puntos ya no se distinguen en un día tan angosto.
  static const _maxDots = 3;

  final DateTime day;
  final bool selected;
  final List<Color> dots;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.md);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? SfColors.primary : SfColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: SfSpacing.xs),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: selected ? SfColors.primary : SfColors.border),
            ),
            child: Column(
              children: [
                Text(
                  CalendarLabels.weekdaysShort[day.weekday - 1],
                  style: SfTypography.caption.copyWith(
                    color: selected ? SfColors.textPrimary : SfColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SfSpacing.xxs),
                Text('${day.day}', style: SfTypography.title),
                const SizedBox(height: SfSpacing.xxs),
                SizedBox(
                  height: _dotSize,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final color in dots.take(_maxDots))
                        Container(
                          width: _dotSize,
                          height: _dotSize,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: selected ? SfColors.textPrimary : color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
