import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/task_form/ui/widgets/grade_part_selector.dart';
import 'package:studyflow/features/task_form/ui/widgets/percent_stepper.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_data.dart';

/// Formulario de tarea. Lo usan Nueva tarea (Figma 14), vacío, y Editar
/// tarea (Figma 19), con los datos cargados en [initial].
///
/// Guarda lo que el usuario elige en el estado de la interfaz y, al tocar el
/// botón, valida título, materia y fecha antes de llamar a [onSubmit].
class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.initial = const TaskFormData(),
  });

  /// Texto del botón: "Guardar tarea" (14) o "Guardar cambios" (19).
  final String submitLabel;

  /// Qué hacer con los datos cuando pasan la validación. Lo decide la
  /// pantalla que usa el formulario (ir a Tarea guardada o volver atrás).
  final ValueChanged<TaskFormData> onSubmit;

  /// Valores con los que arranca el formulario: vacío en Nueva tarea, con
  /// los datos de la tarea en Editar tarea.
  final TaskFormData initial;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  // Cada campo del formulario es una variable de estado que arranca con el
  // valor de widget.initial. Al cambiarla con setState se redibuja el campo.
  late final _title = TextEditingController(text: widget.initial.title);
  late final _place = TextEditingController(text: widget.initial.place);
  late final _notes = TextEditingController(text: widget.initial.notes);
  late DemoSubject? _subject = widget.initial.subject;
  late TaskKind _kind = widget.initial.kind;
  late DateTime? _date = widget.initial.date;
  late TimeOfDay? _time = widget.initial.time;
  late GradePart? _gradePart = widget.initial.gradePart;
  late int _gradeValue = widget.initial.gradeValue;
  late TaskPriority _priority = widget.initial.priority;
  late DeliveryChannel? _channel = widget.initial.channel;
  late bool _reminder = widget.initial.reminder;

  /// Los errores solo se muestran después del primer intento de guardar.
  bool _triedToSave = false;

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// Si es examen se pide el lugar en vez del canal de entrega.
  bool get _isExam => _kind == TaskKind.exam;

  /// Abre el calendario; si el usuario elige una fecha, se guarda.
  Future<void> _pickDate() async {
    final picked = await sfPickDate(context, initial: _date);
    if (picked != null) setState(() => _date = picked);
  }

  /// Abre el reloj; si el usuario elige una hora, se guarda.
  Future<void> _pickTime() async {
    final picked = await sfPickTime(context, initial: _time);
    if (picked != null) setState(() => _time = picked);
  }

  /// Elige la parte de la nota y ajusta el valor de la tarea a ese límite.
  void _selectGradePart(GradePart part) {
    setState(() {
      _gradePart = part;
      // El valor de la tarea no puede pasar lo que vale su parte de la nota.
      if (_gradeValue > part.weight) _gradeValue = part.weight;
    });
  }

  /// Botón de guardar: valida título, materia y fecha. Si falta alguno, se
  /// quedan los errores en pantalla; si no, entrega los datos a onSubmit.
  void _submit() {
    setState(() => _triedToSave = true);
    if (_title.text.trim().isEmpty || _subject == null || _date == null) return;

    widget.onSubmit(
      TaskFormData(
        title: _title.text.trim(),
        subject: _subject,
        kind: _kind,
        date: _date,
        time: _time,
        gradePart: _gradePart,
        gradeValue: _gradeValue,
        priority: _priority,
        channel: _isExam ? null : _channel,
        place: _isExam ? _place.text.trim() : '',
        reminder: _reminder,
        notes: _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SfTextField(
                  label: 'Título',
                  hint: 'Ej.: Taller 3: consultas SQL',
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  errorText: _triedToSave && _title.text.trim().isEmpty ? 'Escribe el título' : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: SfSpacing.md),
                const _FieldLabel('Materia'),
                SfOptionCards<DemoSubject>(
                  columns: 1,
                  selected: _subject,
                  onChanged: (subject) => setState(() => _subject = subject),
                  options: [
                    for (final subject in DemoData.subjects)
                      SfOption(
                        value: subject,
                        label: subject.name,
                        subtitle: subject.professor,
                        icon: Icons.menu_book_outlined,
                        color: subject.color,
                      ),
                  ],
                ),
                if (_triedToSave && _subject == null) const _FieldError('Elige la materia'),
                const SizedBox(height: SfSpacing.md),
                const _FieldLabel('Tipo'),
                SfSegmented<TaskKind>(
                  selected: _kind,
                  onChanged: (kind) => setState(() => _kind = kind),
                  segments: [for (final kind in TaskKind.values) (kind, kind.label)],
                ),
                const SizedBox(height: SfSpacing.md),
                SfPickerField(
                  label: _isExam ? 'Fecha del examen' : 'Fecha de entrega',
                  value: _date == null ? null : sfFormatDate(_date!),
                  placeholder: 'Elegir fecha',
                  onTap: _pickDate,
                ),
                if (_triedToSave && _date == null) const _FieldError('Elige la fecha'),
                const SizedBox(height: SfSpacing.md),
                SfPickerField(
                  label: _isExam ? 'Hora del examen' : 'Hora de entrega',
                  value: _time == null ? null : sfFormatTime(_time!),
                  placeholder: 'Elegir hora',
                  icon: Icons.schedule,
                  onTap: _pickTime,
                ),
                const SizedBox(height: SfSpacing.md),
                const _FieldLabel('Parte de la nota'),
                GradePartSelector(
                  parts: demoGradeParts,
                  selected: _gradePart,
                  onChanged: _selectGradePart,
                ),
                const SizedBox(height: SfSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _FieldLabel('Valor en la nota'),
                          PercentStepper(
                            value: _gradeValue,
                            max: _gradePart?.weight ?? 100,
                            onChanged: (value) => setState(() => _gradeValue = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: SfSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _FieldLabel('Prioridad'),
                          SfSegmented<TaskPriority>(
                            selected: _priority,
                            onChanged: (priority) => setState(() => _priority = priority),
                            segments: [for (final p in TaskPriority.values) (p, p.label)],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_gradePart != null) ...[
                  const SizedBox(height: SfSpacing.xs),
                  Text(
                    '${_gradePart!.label} vale ${_gradePart!.weight} %: esta tarea usa '
                    '$_gradeValue % y quedan ${_gradePart!.weight - _gradeValue} % sin asignar.',
                    style: SfTypography.caption.copyWith(color: SfColors.success),
                  ),
                ],
                const SizedBox(height: SfSpacing.md),
                if (_isExam)
                  SfTextField(
                    label: '¿Dónde es el examen?',
                    hint: 'Salón o edificio',
                    icon: Icons.place_outlined,
                    controller: _place,
                    textCapitalization: TextCapitalization.sentences,
                  )
                else ...[
                  const _FieldLabel('¿Dónde se entrega?'),
                  SfOptionCards<DeliveryChannel>(
                    columns: 1,
                    selected: _channel,
                    onChanged: (channel) => setState(() => _channel = channel),
                    options: [
                      for (final channel in DeliveryChannel.values)
                        SfOption(
                          value: channel,
                          label: channel.label,
                          subtitle: channel.subtitle,
                          icon: channel.icon,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: SfSpacing.md),
                _ReminderCard(
                  value: _reminder,
                  subtitle: _isExam ? '1 día antes del examen' : '1 día antes de la entrega',
                  onChanged: (value) => setState(() => _reminder = value),
                ),
                const SizedBox(height: SfSpacing.md),
                SfTextField(
                  label: 'Notas (opcional)',
                  hint: 'Lo que debes recordar de esta tarea',
                  controller: _notes,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.md),
          child: SfButton(label: widget.submitLabel, onPressed: _submit),
        ),
      ],
    );
  }
}

/// Etiqueta de un campo armado a mano (los Sf* con label ya la traen).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SfSpacing.xs - 2),
      child: Text(text, style: SfTypography.label),
    );
  }
}

/// Mensaje de error debajo de un selector.
class _FieldError extends StatelessWidget {
  const _FieldError(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SfSpacing.xxs),
      child: Text(text, style: SfTypography.caption.copyWith(color: SfColors.danger)),
    );
  }
}

/// Tarjeta con el interruptor del recordatorio.
class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.value, required this.subtitle, required this.onChanged});

  final bool value;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      padding: const EdgeInsets.symmetric(horizontal: SfSpacing.md, vertical: SfSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.alarm, color: SfColors.primaryLight),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recordatorio', style: SfTypography.bodyStrong),
                Text(subtitle, style: SfTypography.caption),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
