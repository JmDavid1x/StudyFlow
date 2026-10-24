import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/calendar/ui/widgets/calendar_labels.dart';

/// Mes y año con las flechas para pasar de semana (Figma 20).
class MonthHeader extends StatelessWidget {
  const MonthHeader({
    super.key,
    required this.date,
    required this.onPrevious,
    required this.onNext,
  });

  /// Cualquier día de la semana que se está viendo.
  final DateTime date;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(CalendarLabels.monthYear(date), style: SfTypography.title)),
        SfIconButton(icon: Icons.chevron_left, tooltip: 'Semana anterior', onPressed: onPrevious),
        const SizedBox(width: SfSpacing.xs),
        SfIconButton(icon: Icons.chevron_right, tooltip: 'Semana siguiente', onPressed: onNext),
      ],
    );
  }
}
