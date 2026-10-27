import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/class_schedule.dart';

/// Hoja inferior "Agregar horario" (Figma S9). Se abre con
/// `showSfBottomSheet<ClassSchedule>` y devuelve el horario elegido.
class ClassScheduleSheet extends StatefulWidget {
  const ClassScheduleSheet({super.key});

  @override
  State<ClassScheduleSheet> createState() => _ClassScheduleSheetState();
}

class _ClassScheduleSheetState extends State<ClassScheduleSheet> {
  static const _days = <(String, String)>[
    ('Lunes', 'Lun'),
    ('Martes', 'Mar'),
    ('Miércoles', 'Mié'),
    ('Jueves', 'Jue'),
    ('Viernes', 'Vie'),
    ('Sábado', 'Sáb'),
  ];

  final _room = TextEditingController(text: 'Salón 401C');
  String _day = 'Martes';
  TimeOfDay _start = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _room.dispose();
    super.dispose();
  }

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  bool get _isValid => _minutes(_end) > _minutes(_start);

  Future<void> _pickStart() async {
    final picked = await sfPickTime(context, initial: _start);
    if (picked == null || !mounted) return;
    setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await sfPickTime(context, initial: _end);
    if (picked == null || !mounted) return;
    setState(() => _end = picked);
  }

  void _add() {
    Navigator.pop(
      context,
      ClassSchedule(day: _day, start: _start, end: _end, room: _room.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Agregar horario', style: SfTypography.h2),
        const SizedBox(height: SfSpacing.xxs),
        Text('Agrega una fila por cada día que tengas clase.', style: SfTypography.caption),
        const SizedBox(height: SfSpacing.sm),
        Text('Día', style: SfTypography.label),
        const SizedBox(height: SfSpacing.xs),
        SfChipBar<String>(
          padding: EdgeInsets.zero,
          options: _days,
          selected: _day,
          onChanged: (day) => setState(() => _day = day),
        ),
        const SizedBox(height: SfSpacing.md),
        SfPickerField(
          label: 'Hora de inicio',
          icon: Icons.access_time_rounded,
          value: sfFormatTime(_start),
          onTap: _pickStart,
        ),
        const SizedBox(height: SfSpacing.md),
        SfPickerField(
          label: 'Hora de fin',
          icon: Icons.access_time_rounded,
          value: sfFormatTime(_end),
          onTap: _pickEnd,
        ),
        if (!_isValid) ...[
          const SizedBox(height: SfSpacing.xs),
          Text(
            'La hora de fin debe ser después de la de inicio.',
            style: SfTypography.caption.copyWith(color: SfColors.danger),
          ),
        ],
        const SizedBox(height: SfSpacing.md),
        SfTextField(
          label: 'Salón (opcional)',
          icon: Icons.location_on_outlined,
          hint: 'Salón 401C',
          controller: _room,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: SfSpacing.lg),
        SfButton(label: 'Agregar horario', onPressed: _isValid ? _add : null),
      ],
    );
  }
}
