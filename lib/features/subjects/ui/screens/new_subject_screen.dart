import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/class_schedule.dart';
import 'package:studyflow/features/subjects/ui/widgets/class_schedule_sheet.dart';
import 'package:studyflow/features/subjects/ui/widgets/dashed_add_button.dart';
import 'package:studyflow/features/subjects/ui/widgets/grade_stepper.dart';
import 'package:studyflow/features/subjects/ui/widgets/schedule_tile.dart';
import 'package:studyflow/features/subjects/ui/widgets/stepper_field.dart';
import 'package:studyflow/features/subjects/ui/widgets/subject_color_picker.dart';
import 'package:studyflow/features/subjects/ui/widgets/subjects_prototype_data.dart';

/// Nueva materia (Figma 09). Desde aquí se abre la hoja S9 "Agregar horario".
///
/// Todo lo que se elige (créditos, color, horario, meta, porcentajes) se
/// cambia con toques, sin teclado. El estado es solo de interfaz; guardar
/// vuelve a la pantalla anterior. En el Sprint 2 se guarda en Supabase.
class NewSubjectScreen extends StatefulWidget {
  const NewSubjectScreen({super.key});

  @override
  State<NewSubjectScreen> createState() => _NewSubjectScreenState();
}

class _NewSubjectScreenState extends State<NewSubjectScreen> {
  static const _minCredits = 1;
  static const _maxCredits = 6;
  static const _percentStep = 5;

  final _name = TextEditingController(text: 'Aplicaciones Móviles');
  final _professor = TextEditingController(text: 'Andrés Ruiz');
  int _credits = 3;
  int _color = 0;
  int _goalTenths = 44;
  final _schedules = <ClassSchedule>[
    const ClassSchedule(
      day: 'Martes',
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 9, minute: 0),
      room: 'Salón 401C',
    ),
    const ClassSchedule(
      day: 'Jueves',
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 9, minute: 0),
      room: 'Salón 401C',
    ),
  ];
  final _percents = <int>[for (final component in prototypeComponents) component.percent];

  @override
  void dispose() {
    _name.dispose();
    _professor.dispose();
    super.dispose();
  }

  Future<void> _addSchedule() async {
    final schedule = await showSfBottomSheet<ClassSchedule>(
      context,
      builder: (_) => const ClassScheduleSheet(),
    );
    if (schedule == null || !mounted) return;
    setState(() => _schedules.add(schedule));
  }

  void _changePercent(int index, int delta) {
    setState(() => _percents[index] = (_percents[index] + delta).clamp(0, 100).toInt());
  }

  @override
  Widget build(BuildContext context) {
    final total = _percents.fold<int>(0, (sum, percent) => sum + percent);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Nueva materia', useCloseIcon: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  SfSpacing.screen,
                  SfSpacing.xs,
                  SfSpacing.screen,
                  SfSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SfTextField(
                      label: 'Nombre',
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: SfSpacing.md),
                    SfTextField(
                      label: 'Profesor',
                      icon: Icons.person_outline,
                      controller: _professor,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: SfSpacing.md),
                    Text('Créditos', style: SfTypography.label),
                    const SizedBox(height: SfSpacing.xs),
                    StepperField(
                      icon: Icons.menu_book_outlined,
                      label: '$_credits ${_credits == 1 ? 'crédito' : 'créditos'}',
                      decrementTooltip: 'Quitar un crédito',
                      incrementTooltip: 'Agregar un crédito',
                      onDecrement: _credits > _minCredits
                          ? () => setState(() => _credits--)
                          : null,
                      onIncrement: _credits < _maxCredits
                          ? () => setState(() => _credits++)
                          : null,
                    ),
                    const SizedBox(height: SfSpacing.md),
                    Text('Color', style: SfTypography.label),
                    const SizedBox(height: SfSpacing.xs),
                    SubjectColorPicker(
                      selected: _color,
                      onChanged: (index) => setState(() => _color = index),
                    ),
                    const SizedBox(height: SfSpacing.md),
                    Text('Horario de clases', style: SfTypography.label),
                    const SizedBox(height: SfSpacing.xxs),
                    Text(
                      'Lo usamos para mostrar tus clases en el calendario y para '
                      'que el asistente no te ponga bloques de estudio encima.',
                      style: SfTypography.caption,
                    ),
                    const SizedBox(height: SfSpacing.xs),
                    if (_schedules.isEmpty)
                      const Center(
                        child: SfEmptyState(
                          icon: Icons.event_outlined,
                          title: 'Aún no hay horarios',
                          message: 'Toca "Agregar horario" para poner el día y la hora '
                              'de tus clases.',
                        ),
                      )
                    else
                      for (var i = 0; i < _schedules.length; i++) ...[
                        ScheduleTile(
                          schedule: _schedules[i],
                          onRemove: () => setState(() => _schedules.removeAt(i)),
                        ),
                        const SizedBox(height: SfSpacing.xs),
                      ],
                    DashedAddButton(label: 'Agregar horario', onPressed: _addSchedule),
                    const SizedBox(height: SfSpacing.lg),
                    Text('Cómo se calcula la nota', style: SfTypography.label),
                    const SizedBox(height: SfSpacing.xs),
                    for (var i = 0; i < prototypeComponents.length; i++) ...[
                      Text(prototypeComponents[i].name, style: SfTypography.caption),
                      const SizedBox(height: SfSpacing.xxs),
                      StepperField(
                        icon: Icons.percent_rounded,
                        label: '${_percents[i]} %',
                        decrementTooltip: 'Bajar porcentaje',
                        incrementTooltip: 'Subir porcentaje',
                        onDecrement: _percents[i] > 0
                            ? () => _changePercent(i, -_percentStep)
                            : null,
                        onIncrement: _percents[i] < 100
                            ? () => _changePercent(i, _percentStep)
                            : null,
                      ),
                      const SizedBox(height: SfSpacing.sm),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            total == 100
                                ? 'Los porcentajes suman 100 %.'
                                : 'Los porcentajes deben sumar 100 %.',
                            style: SfTypography.caption,
                          ),
                        ),
                        SfBadge(
                          label: '$total %',
                          tone: total == 100 ? SfTone.success : SfTone.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.md),
                    Text('Meta de nota', style: SfTypography.label),
                    const SizedBox(height: SfSpacing.xs),
                    GradeStepper(
                      tenths: _goalTenths,
                      onChanged: (value) => setState(() => _goalTenths = value),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SfSpacing.screen,
                SfSpacing.xs,
                SfSpacing.screen,
                SfSpacing.md,
              ),
              child: SfButton(
                label: 'Guardar materia',
                onPressed: _name.text.trim().isEmpty ? null : () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
