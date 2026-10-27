import 'package:flutter/material.dart';

import 'package:studyflow/core/demo/demo_data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/study_blocks/ui/widgets/demo_agenda.dart';

/// Nuevo bloque de estudio (Figma 28). Se elige la tarea que se va a
/// preparar, el día, la hora de inicio, la duración y el aviso. Si llega un
/// bloque como argumento (desde Reprogramar), su tarea viene elegida.
class NewStudyBlockScreen extends StatefulWidget {
  const NewStudyBlockScreen({super.key});

  @override
  State<NewStudyBlockScreen> createState() => _NewStudyBlockScreenState();
}

class _NewStudyBlockScreenState extends State<NewStudyBlockScreen> {
  /// Opciones de los SfChipBar como (minutos, texto que se ve).
  static const _durations = [(30, '30 min'), (60, '1 h'), (90, '1 h 30'), (120, '2 h')];
  static const _reminders = [(0, 'Sin aviso'), (10, '10 min'), (15, '15 min'), (30, '30 min')];

  /// Solo se puede preparar lo que aún no se ha entregado.
  final _tasks = DemoData.tasks.where((task) => !task.done).toList();

  // Lo que el usuario va eligiendo. Duración y aviso arrancan como en Figma.
  DemoTask? _task;
  DateTime? _date;
  TimeOfDay? _time;
  int _duration = 120;
  int _reminder = 15;

  /// Los errores solo se muestran después del primer intento de guardar.
  bool _triedToSave = false;

  /// Evita volver a leer los argumentos de la ruta y pisar lo que el
  /// usuario ya eligió.
  bool _loadedArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Los argumentos de la ruta se leen una sola vez, no en cada build.
    if (_loadedArgs) return;
    _loadedArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is AgendaItem) _task = args.task;
  }

  /// Abre el calendario en el "hoy" del prototipo; guarda el día elegido.
  Future<void> _pickDate() async {
    final picked = await sfPickDate(context, initial: _date ?? DemoAgenda.today);
    if (picked != null) setState(() => _date = picked);
  }

  /// Abre el reloj y guarda la hora de inicio elegida.
  Future<void> _pickTime() async {
    final picked = await sfPickTime(context, initial: _time);
    if (picked != null) setState(() => _time = picked);
  }

  /// Botón "Guardar bloque": valida tarea, día y hora y vuelve atrás.
  /// En el Sprint 1 no se guarda en ningún lado; en el Sprint 2 va a Supabase.
  void _save() {
    setState(() => _triedToSave = true);
    if (_task == null || _date == null || _time == null) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Nuevo bloque de estudio', useCloseIcon: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Reserva tiempo para avanzar en una tarea o estudiar para un examen.',
                      style: SfTypography.body.copyWith(color: SfColors.textSecondary),
                    ),
                    const SizedBox(height: SfSpacing.md),
                    const _FieldLabel('Tarea'),
                    SfOptionCards<DemoTask>(
                      columns: 1,
                      selected: _task,
                      onChanged: (task) => setState(() => _task = task),
                      options: [
                        for (final task in _tasks)
                          SfOption(
                            value: task,
                            label: task.title,
                            subtitle: '${task.subject} · ${task.due}',
                            icon: task.isExam ? Icons.flag_outlined : Icons.assignment_outlined,
                            color: task.color,
                          ),
                      ],
                    ),
                    if (_triedToSave && _task == null) const _FieldError('Elige la tarea'),
                    const SizedBox(height: SfSpacing.md),
                    SfPickerField(
                      label: 'Día',
                      value: _date == null ? null : sfFormatDate(_date!),
                      placeholder: 'Elegir día',
                      onTap: _pickDate,
                    ),
                    if (_triedToSave && _date == null) const _FieldError('Elige el día'),
                    const SizedBox(height: SfSpacing.md),
                    SfPickerField(
                      label: 'Hora de inicio',
                      value: _time == null ? null : sfFormatTime(_time!),
                      placeholder: 'Elegir hora',
                      icon: Icons.schedule,
                      onTap: _pickTime,
                    ),
                    if (_triedToSave && _time == null) const _FieldError('Elige la hora'),
                    const SizedBox(height: SfSpacing.md),
                    const _FieldLabel('Duración'),
                    SfChipBar<int>(
                      padding: EdgeInsets.zero,
                      options: _durations,
                      selected: _duration,
                      onChanged: (minutes) => setState(() => _duration = minutes),
                    ),
                    const SizedBox(height: SfSpacing.md),
                    const _FieldLabel('Avisarme antes'),
                    SfChipBar<int>(
                      padding: EdgeInsets.zero,
                      options: _reminders,
                      selected: _reminder,
                      onChanged: (minutes) => setState(() => _reminder = minutes),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.md),
              child: SfButton(label: 'Guardar bloque', onPressed: _save),
            ),
          ],
        ),
      ),
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
