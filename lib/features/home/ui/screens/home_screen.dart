import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/home/ui/widgets/home_demo.dart';
import 'package:studyflow/features/home/ui/widgets/pending_block_banner.dart';
import 'package:studyflow/features/home/ui/widgets/today_plan_card.dart';
import 'package:studyflow/features/home/ui/widgets/weekly_progress_card.dart';
import 'package:studyflow/features/tasks/ui/widgets/task_navigation.dart';

/// Pestaña Inicio (Figma 11 · 12 · 16): resumen de la semana, el plan del
/// asistente y las tareas de hoy y de los próximos días. La barra inferior la
/// pone MainShell.
///
/// Los tres estados del prototipo viven en esta misma pantalla. En modo debug
/// se cambia entre ellos con una pulsación larga sobre la fecha; en el
/// Sprint 2 el estado sale de los datos de Supabase.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeVariant _variant = HomeVariant.normal;

  /// Títulos de las tareas marcadas como hechas en esta pantalla.
  final Set<String> _checked = {};

  void _nextVariant() {
    setState(() {
      _variant = HomeVariant.values[(_variant.index + 1) % HomeVariant.values.length];
      _checked.clear();
    });
  }

  void _toggle(DemoTask task) {
    setState(() {
      if (!_checked.remove(task.title)) _checked.add(task.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    final empty = _variant == HomeVariant.empty;
    final (done, total) = HomeDemo.weekProgress(_variant);
    final today = HomeDemo.todayTasks(_variant);
    final upcoming = HomeDemo.upcomingTasks(_variant);

    return Scaffold(
      floatingActionButton: SfFab(
        tooltip: 'Nueva tarea',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.newTask),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          // Espacio abajo para que el botón + no tape la última fila.
          padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.md, SfSpacing.screen, SfSpacing.xxl * 2),
          children: [
            _Greeting(
              showAssistant: !empty,
              hasNews: !empty,
              onLongPressDate: kDebugMode ? _nextVariant : null,
            ),
            if (_variant == HomeVariant.normal) ...[
              const SizedBox(height: SfSpacing.md),
              PendingBlockBanner(onTap: () => Navigator.pushNamed(context, AppRoutes.studyBlock)),
            ],
            const SizedBox(height: SfSpacing.md),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SfStatCard(value: HomeDemo.deliveries(_variant), caption: 'entregas esta semana'),
                  ),
                  const SizedBox(width: SfSpacing.xs),
                  Expanded(
                    child: empty
                        ? const SfStatCard(value: '–', caption: 'sin parciales')
                        : const SfStatCard(value: 'Jue', caption: 'parcial de Cálculo'),
                  ),
                  const SizedBox(width: SfSpacing.xs),
                  Expanded(
                    child: SfStatCard(value: empty ? '0 h' : '6 h', caption: 'de estudio planeadas'),
                  ),
                ],
              ),
            ),
            if (empty) ...[
              const SizedBox(height: SfSpacing.xl),
              SfEmptyState(
                icon: Icons.edit_calendar_outlined,
                title: 'Aún no tienes entregas',
                message: 'Agrega la primera y te recordamos antes de que venza.',
                actionLabel: 'Agregar mi primera entrega',
                onAction: () => Navigator.pushNamed(context, AppRoutes.newTask),
              ),
            ] else ...[
              const SizedBox(height: SfSpacing.md),
              WeeklyProgressCard(done: done + _checked.length, total: total),
              const SizedBox(height: SfSpacing.md),
              TodayPlanCard(
                plan: HomeDemo.plan,
                onTalk: () => Navigator.pushNamed(context, AppRoutes.assistant),
              ),
              const SizedBox(height: SfSpacing.lg),
              SfSectionHeader(
                title: 'Prioridades de hoy',
                actionLabel: 'Ver todas',
                onAction: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.main,
                  (_) => false,
                  arguments: AppTabs.tasks,
                ),
              ),
              const SizedBox(height: SfSpacing.xs),
              if (today.isEmpty)
                const SfCard(
                  child: SfEmptyState(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Nada vence hoy',
                    message: 'Adelanta algo de los próximos días o agrega una tarea con el botón +.',
                  ),
                )
              else
                for (final task in today) _tile(task),
              const SizedBox(height: SfSpacing.md),
              const SfSectionHeader(title: 'Próximas'),
              const SizedBox(height: SfSpacing.xs),
              if (upcoming.isEmpty)
                const SfCard(
                  child: SfEmptyState(
                    icon: Icons.event_available_outlined,
                    title: 'Nada para los próximos días',
                    message: 'Cuando agregues una entrega, aparecerá aquí.',
                  ),
                )
              else
                for (final task in upcoming) _tile(task),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tile(DemoTask task) {
    final done = _checked.contains(task.title);
    return Padding(
      padding: const EdgeInsets.only(bottom: SfSpacing.sm),
      child: SfTaskTile(
        title: task.title,
        subtitle: '${task.subject} · ${task.due}',
        subjectColor: task.color,
        done: done,
        trailing: done ? null : SfBadge.priority(task.priority),
        onTap: () => openTaskDetail(context, task),
        onToggle: () => _toggle(task),
      ),
    );
  }
}

/// Fecha, saludo y los botones del asistente y de notificaciones.
class _Greeting extends StatelessWidget {
  const _Greeting({
    required this.showAssistant,
    required this.hasNews,
    this.onLongPressDate,
  });

  final bool showAssistant;
  final bool hasNews;
  final VoidCallback? onLongPressDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onLongPress: onLongPressDate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(HomeDemo.today, style: SfTypography.caption),
                const SizedBox(height: SfSpacing.xxs),
                Text.rich(
                  TextSpan(
                    text: 'Hola, ',
                    children: [
                      TextSpan(
                        text: DemoData.studentName,
                        style: SfTypography.display.copyWith(color: SfColors.primaryLight),
                      ),
                    ],
                  ),
                  style: SfTypography.display,
                ),
              ],
            ),
          ),
        ),
        if (showAssistant) ...[
          SfIconButton(
            icon: Icons.auto_awesome,
            tooltip: 'Asistente',
            filled: true,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.assistant),
          ),
          const SizedBox(width: SfSpacing.xs),
        ],
        SfIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notificaciones',
          showDot: hasNews,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
        ),
      ],
    );
  }
}
