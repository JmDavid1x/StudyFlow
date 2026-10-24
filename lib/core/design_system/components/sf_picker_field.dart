import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_radius.dart';
import 'package:studyflow/core/design_system/tokens/sf_spacing.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

/// Campo que se toca para abrir un selector (fecha, hora, materia...).
/// Se ve como un campo de texto, pero nunca abre el teclado.
class SfPickerField extends StatelessWidget {
  const SfPickerField({
    super.key,
    required this.value,
    required this.onTap,
    this.label,
    this.icon = Icons.calendar_today_outlined,
    this.placeholder = 'Seleccionar',
  });

  /// Texto ya formateado, o null si aún no se elige nada.
  final String? value;
  final VoidCallback onTap;
  final String? label;
  final IconData icon;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.md);
    final field = Material(
      color: SfColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: SfColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: SfColors.textSecondary),
              const SizedBox(width: SfSpacing.sm),
              Expanded(
                child: Text(
                  value ?? placeholder,
                  overflow: TextOverflow.ellipsis,
                  style: SfTypography.body.copyWith(
                    color: value == null ? SfColors.textDisabled : SfColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.expand_more, color: SfColors.textSecondary),
            ],
          ),
        ),
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: SfTypography.label),
        const SizedBox(height: SfSpacing.xs - 2),
        field,
      ],
    );
  }
}

/// Abre el calendario para elegir una fecha.
Future<DateTime?> sfPickDate(
  BuildContext context, {
  DateTime? initial,
  DateTime? first,
  DateTime? last,
}) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initial ?? now,
    firstDate: first ?? DateTime(now.year - 1),
    lastDate: last ?? DateTime(now.year + 2),
    helpText: 'Elige la fecha',
    cancelText: 'Cancelar',
    confirmText: 'Listo',
  );
}

/// Abre el reloj para elegir una hora.
Future<TimeOfDay?> sfPickTime(BuildContext context, {TimeOfDay? initial}) {
  return showTimePicker(
    context: context,
    initialTime: initial ?? TimeOfDay.now(),
    helpText: 'Elige la hora',
    cancelText: 'Cancelar',
    confirmText: 'Listo',
  );
}

const _weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const _months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// "mié 23 sep"
String sfFormatDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';

/// "6:00 p. m."
String sfFormatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${time.period == DayPeriod.am ? 'a. m.' : 'p. m.'}';
}
