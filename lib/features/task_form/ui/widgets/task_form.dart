import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/task_form/domain/porcentaje_componente.dart';
import 'package:studyflow/features/task_form/domain/task_form_repository.dart';
import 'package:studyflow/features/task_form/ui/widgets/grade_part_selector.dart';
import 'package:studyflow/features/task_form/ui/widgets/percent_stepper.dart';
import 'package:studyflow/features/task_form/ui/widgets/task_form_data.dart';

/// Formulario de tarea. Lo usan Nueva tarea (Figma 14), vacío, y Editar
/// tarea (Figma 19), con los datos cargados en [initial].
///
/// Las materias y sus partes de la nota llegan de Supabase por [materias].
/// Guarda lo que el usuario elige en el estado de la interfaz y, al tocar el
/// botón, valida los campos obligatorios antes de llamar a [onSubmit].
class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    required this.materias,
    required this.asignados,
    this.initial = const TaskFormData(),
    this.editingId,
    this.saving = false,
  });

  /// Texto del botón: "Guardar tarea" (14) o "Guardar cambios" (19).
  final String submitLabel;

  /// Qué hacer con los datos cuando pasan la validación.
  final ValueChanged<TaskFormData> onSubmit;

  /// Materias del periodo activo con sus componentes de nota.
  final List<Materia> materias;

  /// Lo que ya usan las actividades de cada componente.
  final List<PorcentajeAsignado> asignados;

  /// Valores con los que arranca el formulario.
  final TaskFormData initial;

  /// Id de la actividad que se edita, para no restarla de su componente.
  final String? editingId;

  /// true mientras se guarda: el botón muestra la carga.
  final bool saving;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late final _title = TextEditingController(text: widget.initial.title);
  late final _place = TextEditingController(text: widget.initial.place);
  late final _notes = TextEditingController(text: widget.initial.notes);
  late Materia? _materia = widget.initial.materia;
  late ComponenteNota? _componente = widget.initial.componente;
  late TipoActividad _tipo = widget.initial.tipo;
  late DateTime? _date = widget.initial.date;
  late TimeOfDay? _time = widget.initial.time;
  late int _porcentaje = widget.initial.porcentaje;
  late Prioridad _prioridad = widget.initial.prioridad;
  late CanalEntrega? _canal = widget.initial.canal;
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

  bool get _isExam => _tipo == TipoActividad.examen;

  /// Lo que le queda libre a la parte de la nota elegida.
  int get _restante => _componente == null
      ? 100
      : porcentajeRestante(
          _componente!,
          widget.asignados,
          sinContar: widget.editingId,
        ).floor();

  Future<void> _pickDate() async {
    final picked = await sfPickDate(context, initial: _date);
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await sfPickTime(context, initial: _time);
    if (picked != null) setState(() => _time = picked);
  }

  /// Al cambiar de materia, la parte de la nota anterior ya no sirve.
  void _selectMateria(Materia materia) {
    if (materia.id == _materia?.id) return;
    setState(() {
      _materia = materia;
      _componente = null;
    });
  }

  void _selectComponente(ComponenteNota componente) {
    setState(() {
      _componente = componente;
      // El valor de la tarea no puede pasar lo que le queda a esa parte.
      if (_porcentaje > _restante) _porcentaje = _restante;
    });
  }

  void _submit() {
    setState(() => _triedToSave = true);
    final falta =
        _title.text.trim().isEmpty ||
        _materia == null ||
        _componente == null ||
        _date == null ||
        (!_isExam && _canal == null);
    if (falta) return;

    widget.onSubmit(
      TaskFormData(
        title: _title.text.trim(),
        materia: _materia,
        componente: _componente,
        tipo: _tipo,
        date: _date,
        time: _time,
        porcentaje: _porcentaje,
        prioridad: _prioridad,
        canal: _isExam ? null : _canal,
        place: _isExam ? _place.text.trim() : '',
        reminder: _reminder,
        notes: _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restante = _restante;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SfSpacing.screen,
              SfSpacing.xs,
              SfSpacing.screen,
              SfSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SfTextField(
                  label: 'Título',
                  hint: 'Ej.: Taller 3: consultas SQL',
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  errorText: _triedToSave && _title.text.trim().isEmpty
                      ? 'Escribe el título'
                      : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: SfSpacing.md),
                const _FieldLabel('Materia'),
                SfOptionCards<Materia>(
                  columns: 1,
                  selected: widget.materias
                      .where((m) => m.id == _materia?.id)
                      .firstOrNull,
                  onChanged: _selectMateria,
                  options: [
                    for (final materia in widget.materias)
                      SfOption(
                        value: materia,
                        label: materia.nombre,
                        subtitle: materia.profesor,
                        icon: Icons.menu_book_outlined,
                        color: materia.color,
                      ),
                  ],
                ),
                if (_triedToSave && _materia == null)
                  const _FieldError('Elige la materia'),
                const SizedBox(height: SfSpacing.md),
                const _FieldLabel('Tipo'),
                SfSegmented<TipoActividad>(
                  selected: _tipo,
                  onChanged: (tipo) => setState(() => _tipo = tipo),
                  segments: [
                    for (final tipo in TipoActividad.values) (tipo, tipo.texto),
                  ],
                ),
                const SizedBox(height: SfSpacing.md),
                SfPickerField(
                  label: _isExam ? 'Fecha del examen' : 'Fecha de entrega',
                  value: _date == null ? null : sfFormatDate(_date!),
                  placeholder: 'Elegir fecha',
                  onTap: _pickDate,
                ),
                if (_triedToSave && _date == null)
                  const _FieldError('Elige la fecha'),
                const SizedBox(height: SfSpacing.md),
                SfPickerField(
                  label: _isExam ? 'Hora del examen' : 'Hora de entrega',
                  value: _time == null ? null : sfFormatTime(_time!),
                  placeholder: 'Elegir hora (si no, 11:59 p. m.)',
                  icon: Icons.schedule,
                  onTap: _pickTime,
                ),
                const SizedBox(height: SfSpacing.md),
                const _FieldLabel('Parte de la nota'),
                if (_materia == null)
                  Text('Elige primero la materia.', style: SfTypography.caption)
                else if (_materia!.componentes.isEmpty)
                  Text(
                    'Esta materia aún no tiene partes de la nota.',
                    style: SfTypography.caption,
                  )
                else
                  GradePartSelector(
                    parts: _materia!.componentes,
                    selected: _componente,
                    onChanged: _selectComponente,
                  ),
                if (_triedToSave && _materia != null && _componente == null)
                  const _FieldError('Elige la parte de la nota'),
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
                            value: _porcentaje,
                            min: 0,
                            max: restante,
                            onChanged: (value) =>
                                setState(() => _porcentaje = value),
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
                          SfSegmented<Prioridad>(
                            selected: _prioridad,
                            onChanged: (prioridad) =>
                                setState(() => _prioridad = prioridad),
                            segments: [
                              for (final p in Prioridad.values) (p, p.texto),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_componente != null) ...[
                  const SizedBox(height: SfSpacing.xs),
                  Text(
                    '${_componente!.nombre} vale ${_componente!.porcentaje.round()} %: '
                    'esta tarea usa $_porcentaje % y quedan '
                    '${restante - _porcentaje} % sin asignar.',
                    style: SfTypography.caption.copyWith(
                      color: SfColors.success,
                    ),
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
                  SfOptionCards<CanalEntrega>(
                    columns: 1,
                    selected: _canal,
                    onChanged: (canal) => setState(() => _canal = canal),
                    options: [
                      for (final canal in CanalEntrega.values)
                        SfOption(
                          value: canal,
                          label: canal.texto,
                          subtitle: canal.subtitulo,
                          icon: canal.icono,
                        ),
                    ],
                  ),
                  if (_triedToSave && _canal == null)
                    const _FieldError('Elige dónde se entrega'),
                ],
                const SizedBox(height: SfSpacing.md),
                _ReminderCard(
                  value: _reminder,
                  subtitle: _isExam
                      ? '1 día antes del examen'
                      : '1 día antes de la entrega',
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
          padding: const EdgeInsets.fromLTRB(
            SfSpacing.screen,
            SfSpacing.xs,
            SfSpacing.screen,
            SfSpacing.md,
          ),
          child: SfButton(
            label: widget.submitLabel,
            isLoading: widget.saving,
            onPressed: _submit,
          ),
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
      child: Text(
        text,
        style: SfTypography.caption.copyWith(color: SfColors.danger),
      ),
    );
  }
}

/// Tarjeta con el interruptor del recordatorio.
class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.value,
    required this.subtitle,
    required this.onChanged,
  });

  final bool value;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      padding: const EdgeInsets.symmetric(
        horizontal: SfSpacing.md,
        vertical: SfSpacing.sm,
      ),
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
