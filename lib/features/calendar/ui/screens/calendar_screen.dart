import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/calendar/ui/widgets/add_sheet.dart';
import 'package:studyflow/features/calendar/ui/widgets/agenda_item_tile.dart';
import 'package:studyflow/features/calendar/ui/widgets/calendar_labels.dart';
import 'package:studyflow/features/calendar/ui/widgets/month_header.dart';
import 'package:studyflow/features/calendar/ui/widgets/week_strip.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/demo_agenda.dart';

/// Pestaña Calendario (Figma 20). Muestra una semana, el día elegido y su
/// agenda por hora. El botón + abre S7 Agregar. La barra inferior la pone
/// MainShell.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  /// Día que se está viendo. Arranca en el "hoy" del prototipo.
  DateTime _selected = DemoAgenda.today;

  /// Lunes de la semana del día elegido.
  DateTime get _weekStart => _selected.subtract(Duration(days: _selected.weekday - 1));

  void _moveWeek(int weeks) {
    setState(() => _selected = _selected.add(Duration(days: 7 * weeks)));
  }

  List<Color> _dotsFor(DateTime day) => [
        for (final item in DemoAgenda.forDay(day))
          if (item.isPending) item.subject.color,
      ];

  void _openItem(AgendaItem item) {
    final route = switch (item.kind) {
      AgendaKind.studyBlock => AppRoutes.studyBlock,
      AgendaKind.exam => AppRoutes.examDetail,
      _ => AppRoutes.taskDetail,
    };
    Navigator.pushNamed(context, route, arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    final items = DemoAgenda.forDay(_selected);
    final pending = items.where((item) => item.isPending).length;
    final isToday = DateUtils.isSameDay(_selected, DemoAgenda.today);

    return Scaffold(
      floatingActionButton: SfFab(onPressed: () => showAddSheet(context)),
      body: SafeArea(
        bottom: false,
        child: ListView(
          // Espacio abajo para que el botón + no tape la última fila.
          padding: const EdgeInsets.only(bottom: SfSpacing.xxl * 2),
          children: [
            const SfLargeTitle(title: 'Calendario'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SfSpacing.screen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MonthHeader(
                    date: _weekStart,
                    onPrevious: () => _moveWeek(-1),
                    onNext: () => _moveWeek(1),
                  ),
                  const SizedBox(height: SfSpacing.sm),
                  WeekStrip(
                    weekStart: _weekStart,
                    selected: _selected,
                    onSelect: (day) => setState(() => _selected = day),
                    dotsFor: _dotsFor,
                  ),
                  const SizedBox(height: SfSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isToday
                              ? 'Hoy, ${CalendarLabels.dayTitle(_selected).toLowerCase()}'
                              : CalendarLabels.dayTitle(_selected),
                          style: SfTypography.h2,
                        ),
                      ),
                      Text(
                        switch (pending) {
                          0 => 'Libre',
                          1 => '1 pendiente',
                          _ => '$pending pendientes',
                        },
                        style: SfTypography.label.copyWith(
                          color: pending == 0 ? SfColors.textSecondary : SfColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SfSpacing.md),
                  if (items.isEmpty)
                    SfCard(
                      child: SfEmptyState(
                        icon: Icons.event_available_outlined,
                        title: 'No tienes nada este día',
                        message: 'Aprovecha para adelantar algo.',
                        actionLabel: 'Agregar bloque de estudio',
                        onAction: () => Navigator.pushNamed(context, AppRoutes.newStudyBlock),
                      ),
                    )
                  else
                    for (final item in items) ...[
                      AgendaItemTile(
                        item: item,
                        onTap: item.kind == AgendaKind.classSession ? null : () => _openItem(item),
                      ),
                      const SizedBox(height: SfSpacing.sm),
                    ],
                  const SizedBox(height: SfSpacing.xs),
                  Text(
                    'Los puntos marcan los días con entregas o bloques sin completar.',
                    style: SfTypography.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
