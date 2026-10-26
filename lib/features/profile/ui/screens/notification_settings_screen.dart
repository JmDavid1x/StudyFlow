import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/profile/ui/widgets/notification_setting_card.dart';

/// Ajustes de notificaciones (Figma 26). Sprint 1: los valores solo viven en
/// la pantalla; en el Sprint 2 se guardan en Supabase.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  var _deliveries = true;
  var _daysBefore = 1;
  var _deliveryTime = const TimeOfDay(hour: 19, minute: 0);

  var _studyBlocks = true;
  var _blockMinutes = 15;

  var _dailyPlan = true;
  var _dailyPlanTime = const TimeOfDay(hour: 6, minute: 30);

  var _weeklySummary = false;
  var _summaryDay = DateTime.sunday;
  var _summaryTime = const TimeOfDay(hour: 18, minute: 0);

  Future<void> _pickTime(TimeOfDay current, ValueChanged<TimeOfDay> onPicked) async {
    final picked = await sfPickTime(context, initial: current);
    if (picked != null) setState(() => onPicked(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Ajustes de notificaciones'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Elige qué te avisamos y cuándo.',
                      style: SfTypography.body.copyWith(color: SfColors.textSecondary),
                    ),
                    const SizedBox(height: SfSpacing.md),
                    NotificationSettingCard(
                      icon: Icons.assignment_outlined,
                      title: 'Entregas',
                      subtitle: 'Antes de que venza una tarea o un examen',
                      enabled: _deliveries,
                      onChanged: (value) => setState(() => _deliveries = value),
                      children: [
                        Text('Días antes', style: SfTypography.label),
                        SfSegmented<int>(
                          segments: const [(1, '1 día'), (2, '2 días'), (3, '3 días')],
                          selected: _daysBefore,
                          onChanged: (value) => setState(() => _daysBefore = value),
                        ),
                        SfPickerField(
                          label: 'Hora del aviso',
                          icon: Icons.schedule_rounded,
                          value: sfFormatTime(_deliveryTime),
                          onTap: () => _pickTime(_deliveryTime, (time) => _deliveryTime = time),
                        ),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.sm),
                    NotificationSettingCard(
                      icon: Icons.timer_outlined,
                      title: 'Bloques de estudio',
                      subtitle: 'Antes de empezar cada bloque',
                      enabled: _studyBlocks,
                      onChanged: (value) => setState(() => _studyBlocks = value),
                      children: [
                        Text('Minutos antes', style: SfTypography.label),
                        SfSegmented<int>(
                          segments: const [(5, '5 min'), (15, '15 min'), (30, '30 min')],
                          selected: _blockMinutes,
                          onChanged: (value) => setState(() => _blockMinutes = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.sm),
                    NotificationSettingCard(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Plan del día',
                      subtitle: 'Lo que tienes para hoy, cada mañana',
                      enabled: _dailyPlan,
                      onChanged: (value) => setState(() => _dailyPlan = value),
                      children: [
                        SfPickerField(
                          label: 'Hora del aviso',
                          icon: Icons.schedule_rounded,
                          value: sfFormatTime(_dailyPlanTime),
                          onTap: () => _pickTime(_dailyPlanTime, (time) => _dailyPlanTime = time),
                        ),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.sm),
                    NotificationSettingCard(
                      icon: Icons.insights_outlined,
                      title: 'Resumen semanal',
                      subtitle: 'Cómo te fue y qué viene la próxima semana',
                      enabled: _weeklySummary,
                      onChanged: (value) => setState(() => _weeklySummary = value),
                      children: [
                        Text('Día', style: SfTypography.label),
                        SfSegmented<int>(
                          segments: const [(DateTime.sunday, 'Domingo'), (DateTime.monday, 'Lunes')],
                          selected: _summaryDay,
                          onChanged: (value) => setState(() => _summaryDay = value),
                        ),
                        SfPickerField(
                          label: 'Hora del aviso',
                          icon: Icons.schedule_rounded,
                          value: sfFormatTime(_summaryTime),
                          onTap: () => _pickTime(_summaryTime, (time) => _summaryTime = time),
                        ),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.lg),
                    SfButton(
                      label: 'Guardar cambios',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
