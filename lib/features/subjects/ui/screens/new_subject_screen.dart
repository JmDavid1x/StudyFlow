import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/subjects/data/subjects_repository_impl.dart';
import 'package:studyflow/features/subjects/domain/componentes_por_defecto.dart';
import 'package:studyflow/features/subjects/domain/usecases/guardar_materia.dart';
import 'package:studyflow/features/subjects/ui/bloc/new_subject_cubit.dart';
import 'package:studyflow/features/subjects/ui/widgets/class_schedule.dart';
import 'package:studyflow/features/subjects/ui/widgets/class_schedule_sheet.dart';
import 'package:studyflow/features/subjects/ui/widgets/conversiones_materia.dart';
import 'package:studyflow/features/subjects/ui/widgets/dashed_add_button.dart';
import 'package:studyflow/features/subjects/ui/widgets/grade_stepper.dart';
import 'package:studyflow/features/subjects/ui/widgets/schedule_tile.dart';
import 'package:studyflow/features/subjects/ui/widgets/stepper_field.dart';
import 'package:studyflow/features/subjects/ui/widgets/subject_color_picker.dart';

/// Nueva materia (Figma 09). Desde aquí se abre la hoja S9 "Agregar horario".
///
/// Todo lo que se elige (créditos, color, horario, meta, porcentajes) se
/// cambia con toques, sin teclado. Al guardar se crea la materia en Supabase
/// (y el periodo, si es la primera) y se vuelve a la pantalla anterior.
class NewSubjectScreen extends StatelessWidget {
  const NewSubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NewSubjectCubit(GuardarMateria(SubjectsRepositoryImpl(supabase))),
      child: const _NewSubjectView(),
    );
  }
}

class _NewSubjectView extends StatefulWidget {
  const _NewSubjectView();

  @override
  State<_NewSubjectView> createState() => _NewSubjectViewState();
}

class _NewSubjectViewState extends State<_NewSubjectView> {
  static const _minCredits = 1;
  static const _maxCredits = 6;
  static const _percentStep = 5;

  final _name = TextEditingController();
  final _professor = TextEditingController();
  int _credits = 3;
  int _color = 0;
  int _goalTenths = 40;
  final _schedules = <ClassSchedule>[];
  final _percents = <int>[for (final c in componentesPorDefecto) c.porcentaje];

  @override
  void dispose() {
    _name.dispose();
    _professor.dispose();
    super.dispose();
  }

  int get _total => _percents.fold<int>(0, (sum, percent) => sum + percent);

  Future<void> _addSchedule() async {
    final schedule = await showSfBottomSheet<ClassSchedule>(
      context,
      builder: (_) => const ClassScheduleSheet(),
    );
    if (schedule == null || !mounted) return;
    setState(() => _schedules.add(schedule));
  }

  void _changePercent(int index, int delta) {
    setState(
      () => _percents[index] = (_percents[index] + delta).clamp(0, 100).toInt(),
    );
  }

  void _save() {
    context.read<NewSubjectCubit>().guardar(
      nombre: _name.text,
      profesor: _professor.text,
      creditos: _credits,
      colorHex: colorAHex(SfColors.subjectColors[_color]),
      metaNota: _goalTenths / 10,
      horarios: [for (final s in _schedules) horarioDesdeClase(s)],
      componentes: [
        for (var i = 0; i < componentesPorDefecto.length; i++)
          ComponenteNota(
            id: '',
            materiaId: '',
            nombre: componentesPorDefecto[i].nombre,
            porcentaje: _percents[i].toDouble(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;

    return BlocConsumer<NewSubjectCubit, NewSubjectState>(
      listenWhen: (anterior, actual) =>
          (!anterior.guardada && actual.guardada) ||
          (anterior.error != actual.error && actual.error != null),
      listener: (context, state) {
        if (state.guardada) {
          Navigator.pop(context);
        } else if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final puedeGuardar =
            _name.text.trim().isNotEmpty && total == 100 && !state.guardando;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SfScreenHeader(
                  title: 'Nueva materia',
                  useCloseIcon: true,
                ),
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
                          hint: 'Aplicaciones Móviles',
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: SfSpacing.md),
                        SfTextField(
                          label: 'Profesor',
                          hint: 'Andrés Ruiz',
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
                          label:
                              '$_credits ${_credits == 1 ? 'crédito' : 'créditos'}',
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
                              message:
                                  'Toca "Agregar horario" para poner el día y la hora de tus clases.',
                            ),
                          )
                        else
                          for (var i = 0; i < _schedules.length; i++) ...[
                            ScheduleTile(
                              schedule: _schedules[i],
                              onRemove: () =>
                                  setState(() => _schedules.removeAt(i)),
                            ),
                            const SizedBox(height: SfSpacing.xs),
                          ],
                        DashedAddButton(
                          label: 'Agregar horario',
                          onPressed: _addSchedule,
                        ),
                        const SizedBox(height: SfSpacing.lg),
                        Text(
                          'Cómo se calcula la nota',
                          style: SfTypography.label,
                        ),
                        const SizedBox(height: SfSpacing.xs),
                        for (
                          var i = 0;
                          i < componentesPorDefecto.length;
                          i++
                        ) ...[
                          Text(
                            componentesPorDefecto[i].nombre,
                            style: SfTypography.caption,
                          ),
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
                              tone: total == 100
                                  ? SfTone.success
                                  : SfTone.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: SfSpacing.md),
                        Text('Meta de nota', style: SfTypography.label),
                        const SizedBox(height: SfSpacing.xs),
                        GradeStepper(
                          tenths: _goalTenths,
                          onChanged: (value) =>
                              setState(() => _goalTenths = value),
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
                    onPressed: puedeGuardar ? _save : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
