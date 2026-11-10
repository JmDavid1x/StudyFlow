import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/calendar/data/calendar_repository_impl.dart';
import 'package:studyflow/features/study_blocks/data/study_blocks_repository_impl.dart';
import 'package:studyflow/features/study_blocks/ui/bloc/new_study_block_cubit.dart';

/// Nuevo bloque de estudio (Figma 28). Se elige la tarea que se va a
/// preparar, el día, la hora de inicio, la duración y el aviso.
/// - Con una [Actividad] como argumento, esa tarea viene elegida.
/// - Con un [BloqueEstudio] (Reprogramar), solo se cambia su hora.
/// Al guardar vuelve atrás con `true`.
class NewStudyBlockScreen extends StatelessWidget {
  const NewStudyBlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return BlocProvider(
      create: (_) => NewStudyBlockCubit(
        StudyBlocksRepositoryImpl(supabase),
        CalendarRepositoryImpl(supabase),
      )..cargar(),
      child: _NewStudyBlockView(
        actividadInicial: args is Actividad ? args : null,
        reprogramar: args is BloqueEstudio ? args : null,
      ),
    );
  }
}

class _NewStudyBlockView extends StatefulWidget {
  const _NewStudyBlockView({this.actividadInicial, this.reprogramar});

  final Actividad? actividadInicial;
  final BloqueEstudio? reprogramar;

  @override
  State<_NewStudyBlockView> createState() => _NewStudyBlockViewState();
}

class _NewStudyBlockViewState extends State<_NewStudyBlockView> {
  /// Opciones de los SfChipBar como (minutos, texto que se ve).
  static const _durations = [
    (30, '30 min'),
    (60, '1 h'),
    (90, '1 h 30'),
    (120, '2 h'),
  ];
  static const _reminders = [
    (0, 'Sin aviso'),
    (10, '10 min'),
    (15, '15 min'),
    (30, '30 min'),
  ];

  late String? _actividadId =
      widget.reprogramar?.actividadId ?? widget.actividadInicial?.id;
  late DateTime? _date = _diaDe(widget.reprogramar?.inicio);
  late TimeOfDay? _time = widget.reprogramar == null
      ? null
      : TimeOfDay.fromDateTime(widget.reprogramar!.inicio);
  late int _duration = widget.reprogramar?.duracion.inMinutes ?? 120;
  late int _reminder = widget.reprogramar?.avisoMin ?? 15;

  /// Los errores solo se muestran después del primer intento de guardar.
  bool _triedToSave = false;

  bool get _esReprogramar => widget.reprogramar != null;

  static DateTime? _diaDe(DateTime? t) =>
      t == null ? null : DateTime(t.year, t.month, t.day);

  /// Si el bloque que se reprograma dura algo que no está en las opciones,
  /// se agrega su duración para no cambiarla sin querer.
  List<(int, String)> get _opcionesDuracion => [
    ..._durations,
    if (!_durations.any((d) => d.$1 == _duration))
      (_duration, '$_duration min'),
  ];

  Future<void> _pickDate() async {
    final picked = await sfPickDate(context, initial: _date ?? DateTime.now());
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await sfPickTime(context, initial: _time);
    if (picked != null) setState(() => _time = picked);
  }

  /// Botón "Guardar bloque": valida tarea, día y hora; los cruces con clases
  /// u otros bloques los revisa el Cubit con la regla de validar_bloque.
  void _save() {
    setState(() => _triedToSave = true);
    if (_actividadId == null || _date == null || _time == null) return;
    context.read<NewStudyBlockCubit>().guardar(
      inicio: DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _time!.hour,
        _time!.minute,
      ),
      minutos: _duration,
      actividadId: _actividadId,
      avisoMin: _reminder == 0 ? null : _reminder,
      reprogramar: widget.reprogramar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewStudyBlockCubit, NewStudyBlockState>(
      listenWhen: (antes, ahora) =>
          antes.guardado != ahora.guardado ||
          antes.errorGuardar != ahora.errorGuardar,
      listener: (context, state) {
        if (state.guardado) {
          Navigator.pop(context, true);
        } else if (state.errorGuardar != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorGuardar!)));
        }
      },
      builder: (context, state) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SfScreenHeader(
                title: _esReprogramar
                    ? 'Reprogramar bloque'
                    : 'Nuevo bloque de estudio',
                useCloseIcon: true,
              ),
              Expanded(child: _cuerpo(context, state)),
              if (state.status == NewStudyBlockStatus.listo)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SfSpacing.screen,
                    SfSpacing.xs,
                    SfSpacing.screen,
                    SfSpacing.md,
                  ),
                  child: SfButton(
                    label: 'Guardar bloque',
                    isLoading: state.guardando,
                    onPressed: _save,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cuerpo(BuildContext context, NewStudyBlockState state) {
    switch (state.status) {
      case NewStudyBlockStatus.cargando:
        return const SfLoadingState(message: 'Cargando tus tareas...');
      case NewStudyBlockStatus.error:
        return Center(
          child: SingleChildScrollView(
            child: SfErrorState(
              message: state.errorCarga ?? 'No pudimos cargar tus tareas.',
              onRetry: () => context.read<NewStudyBlockCubit>().cargar(),
            ),
          ),
        );
      case NewStudyBlockStatus.listo:
        if (state.actividades.isEmpty && !_esReprogramar) {
          return Center(
            child: SingleChildScrollView(
              child: SfEmptyState(
                icon: Icons.task_alt,
                title: 'No tienes tareas pendientes',
                message:
                    'Crea una tarea primero para reservar tiempo de estudio.',
                actionLabel: 'Volver',
                onAction: () => Navigator.pop(context),
              ),
            ),
          );
        }
        return _formulario(state.actividades);
    }
  }

  Widget _formulario(List<Actividad> actividades) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SfSpacing.screen,
        SfSpacing.xs,
        SfSpacing.screen,
        SfSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _esReprogramar
                ? 'Elige la nueva hora para "${widget.reprogramar!.actividadTitulo ?? 'tu bloque'}".'
                : 'Reserva tiempo para avanzar en una tarea o estudiar para un examen.',
            style: SfTypography.body.copyWith(color: SfColors.textSecondary),
          ),
          const SizedBox(height: SfSpacing.md),
          // Al reprogramar la tarea no cambia: solo la hora.
          if (!_esReprogramar) ...[
            const _FieldLabel('Tarea'),
            SfOptionCards<String>(
              columns: 1,
              selected: _actividadId,
              onChanged: (id) => setState(() => _actividadId = id),
              options: [
                for (final actividad in actividades)
                  SfOption(
                    value: actividad.id,
                    label: actividad.titulo,
                    subtitle: [
                      ?actividad.materiaNombre,
                      sfFormatDate(actividad.fechaLimite),
                    ].join(' · '),
                    icon: actividad.esExamen
                        ? Icons.flag_outlined
                        : Icons.assignment_outlined,
                    color: actividad.materiaColor,
                  ),
              ],
            ),
            if (_triedToSave && _actividadId == null)
              const _FieldError('Elige la tarea'),
            const SizedBox(height: SfSpacing.md),
          ],
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
            options: _opcionesDuracion,
            selected: _duration,
            onChanged: (minutes) => setState(() => _duration = minutes),
          ),
          if (!_esReprogramar) ...[
            const SizedBox(height: SfSpacing.md),
            const _FieldLabel('Avisarme antes'),
            SfChipBar<int>(
              padding: EdgeInsets.zero,
              options: _reminders,
              selected: _reminder,
              onChanged: (minutes) => setState(() => _reminder = minutes),
            ),
          ],
        ],
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
      child: Text(
        text,
        style: SfTypography.caption.copyWith(color: SfColors.danger),
      ),
    );
  }
}
