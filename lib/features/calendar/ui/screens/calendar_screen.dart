import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/calendar/ui/widgets/add_sheet.dart';
import 'package:studyflow/features/calendar/ui/widgets/agenda_item_tile.dart';
import 'package:studyflow/features/calendar/ui/widgets/calendar_labels.dart';
import 'package:studyflow/features/calendar/ui/widgets/month_header.dart';
import 'package:studyflow/features/calendar/ui/widgets/week_strip.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/block_completed_sheet.dart';
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

  /// Bloques completados en esta sesión. En el Sprint 1 no hay base de
  /// datos, así que se guardan aquí y se pierden al cerrar la app.
  final Set<AgendaItem> _completed = {};

  void _moveWeek(int weeks) {
    setState(() => _selected = _selected.add(Duration(days: 7 * weeks)));
  }

  /// Pendiente de verdad: no está hecho ni se completó en esta sesión.
  bool _isPending(AgendaItem item) => item.isPending && !_completed.contains(item);

  List<Color> _dotsFor(DateTime day) => [
        for (final item in DemoAgenda.forDay(day))
          if (_isPending(item)) item.subject.color,
      ];

  void _completeBlock(AgendaItem block) {
    setState(() => _completed.add(block));
    // closeScreen en false: desde la pestaña solo se cierra la hoja.
    showBlockCompletedSheet(context, block, closeScreen: false);
  }

  /// El bloque se abre con el AgendaItem completo (StudyBlockScreen lo
  /// espera así); las entregas y los exámenes, con su tarea (DemoTask).
  void _openItem(AgendaItem item) {
    switch (item.kind) {
      case AgendaKind.studyBlock:
        Navigator.pushNamed(context, AppRoutes.studyBlock, arguments: item);
      case AgendaKind.exam:
        Navigator.pushNamed(context, AppRoutes.examDetail, arguments: item.task);
      case AgendaKind.delivery:
        Navigator.pushNamed(context, AppRoutes.taskDetail, arguments: item.task);
      case AgendaKind.classSession:
        break; // Las clases no abren ninguna pantalla.
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = DemoAgenda.forDay(_selected);
    final pending = items.where(_isPending).length;
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
                        onComplete: item.kind == AgendaKind.studyBlock ? () => _completeBlock(item) : null,
                        completed: _completed.contains(item),
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
