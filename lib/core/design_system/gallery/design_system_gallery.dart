import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Muestra todos los tokens y componentes en una sola pantalla. Sirve para
/// revisarlos sin tener que navegar por la app, y para la sustentación.
class DesignSystemGallery extends StatefulWidget {
  const DesignSystemGallery({super.key});

  @override
  State<DesignSystemGallery> createState() => _DesignSystemGalleryState();
}

class _DesignSystemGalleryState extends State<DesignSystemGallery> {
  String _filter = 'todas';
  String _period = 'semestre';
  String? _type = 'tarea';
  DateTime? _date;
  TimeOfDay? _time;
  bool _done = false;
  bool _switch = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Design system'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.xxl),
                children: [
                  const _Section('Colores'),
                  const _Swatches(),
                  const _Section('Tipografía'),
                  Text('Display · Calendario', style: SfTypography.display),
                  Text('H1 · Crea tu cuenta', style: SfTypography.h1),
                  Text('H2 · Prioridades de hoy', style: SfTypography.h2),
                  Text('Title · Materia', style: SfTypography.title),
                  Text('Body strong · Taller 3: consultas SQL', style: SfTypography.bodyStrong),
                  Text('Body · Empieza por la lectura antes de las 6:00 p. m.', style: SfTypography.body),
                  Text('Caption · Bases de Datos · hoy 11:59 p. m.', style: SfTypography.caption),
                  Text('Number · 4.1 · 30 %', style: SfTypography.number),
                  const _Section('Botones'),
                  SfButton(label: 'Guardar tarea', onPressed: () {}),
                  const SizedBox(height: SfSpacing.xs),
                  SfButton(label: 'Registrar nota', icon: Icons.star_outline, variant: SfButtonVariant.secondary, onPressed: () {}),
                  const SizedBox(height: SfSpacing.xs),
                  SfButton(label: 'Seguir con el plan gratis', variant: SfButtonVariant.ghost, onPressed: () {}),
                  const SizedBox(height: SfSpacing.xs),
                  SfButton(label: 'Eliminar tarea', variant: SfButtonVariant.danger, onPressed: () {}),
                  const SizedBox(height: SfSpacing.xs),
                  const SfButton(label: 'Guardando', isLoading: true, onPressed: null),
                  const SizedBox(height: SfSpacing.sm),
                  Row(
                    children: [
                      SfIconButton(icon: Icons.chevron_left, tooltip: 'Atrás', onPressed: () {}),
                      const SizedBox(width: SfSpacing.sm),
                      SfIconButton(icon: Icons.notifications_none, tooltip: 'Notificaciones', showDot: true, onPressed: () {}),
                      const SizedBox(width: SfSpacing.sm),
                      SfIconButton(icon: Icons.chat_bubble_outline, tooltip: 'Asistente', filled: true, onPressed: () {}),
                      const Spacer(),
                      SfFab(onPressed: () {}),
                    ],
                  ),
                  const _Section('Campos y selectores'),
                  const SfTextField(label: 'Correo', hint: 'tu.correo@u.icesi.edu.co', icon: Icons.mail_outline),
                  const SizedBox(height: SfSpacing.sm),
                  const SfTextField(label: 'Contraseña', hint: 'Mínimo 6 caracteres', icon: Icons.lock_outline, isPassword: true),
                  const SizedBox(height: SfSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: SfPickerField(
                          label: 'Fecha',
                          value: _date == null ? null : sfFormatDate(_date!),
                          onTap: () async {
                            final picked = await sfPickDate(context, initial: _date);
                            if (picked != null) setState(() => _date = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: SfSpacing.sm),
                      Expanded(
                        child: SfPickerField(
                          label: 'Hora',
                          icon: Icons.schedule,
                          value: _time == null ? null : sfFormatTime(_time!),
                          onTap: () async {
                            final picked = await sfPickTime(context, initial: _time);
                            if (picked != null) setState(() => _time = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SfSpacing.sm),
                  SfOptionCards<String>(
                    selected: _type,
                    onChanged: (value) => setState(() => _type = value),
                    columns: 3,
                    options: const [
                      SfOption(value: 'tarea', label: 'Tarea', icon: Icons.edit_note),
                      SfOption(value: 'proyecto', label: 'Proyecto', icon: Icons.folder_outlined),
                      SfOption(value: 'examen', label: 'Examen', icon: Icons.school_outlined),
                    ],
                  ),
                  const SizedBox(height: SfSpacing.sm),
                  SfSegmented<String>(
                    selected: _period,
                    onChanged: (value) => setState(() => _period = value),
                    segments: const [('mensual', 'Mensual'), ('semestre', 'Semestre')],
                  ),
                  const SizedBox(height: SfSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _switch,
                    onChanged: (value) => setState(() => _switch = value),
                    title: Text('Recordarme un día antes', style: SfTypography.body),
                  ),
                  const _Section('Chips'),
                  SfChipBar<String>(
                    padding: EdgeInsets.zero,
                    selected: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                    options: const [('todas', 'Todas'), ('hoy', 'Hoy'), ('semana', 'Esta semana'), ('hechas', 'Completadas')],
                  ),
                  const _Section('Tarjetas y filas'),
                  const Row(
                    children: [
                      Expanded(child: SfStatCard(value: '4', caption: 'entregas esta semana')),
                      SizedBox(width: SfSpacing.sm),
                      Expanded(child: SfStatCard(value: '6 h', caption: 'de estudio planeadas')),
                    ],
                  ),
                  const SizedBox(height: SfSpacing.sm),
                  SfTaskTile(
                    title: 'Taller 3: consultas SQL',
                    subtitle: 'Bases de Datos · hoy 11:59 p. m.',
                    subjectColor: SfColors.info,
                    done: _done,
                    onToggle: () => setState(() => _done = !_done),
                    trailing: SfBadge.priority('alta'),
                  ),
                  const SizedBox(height: SfSpacing.sm),
                  SfCard(
                    highlighted: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tu plan de hoy', style: SfTypography.title),
                        const SizedBox(height: SfSpacing.xs),
                        Text('Tarjeta destacada: lo primero que el usuario debe mirar.', style: SfTypography.body),
                      ],
                    ),
                  ),
                  const SizedBox(height: SfSpacing.sm),
                  const Wrap(
                    spacing: SfSpacing.xs,
                    runSpacing: SfSpacing.xs,
                    children: [
                      SfBadge(label: 'Recién completada', tone: SfTone.success),
                      SfBadge(label: 'Vencida', tone: SfTone.danger),
                      SfBadge(label: 'Media', tone: SfTone.warning),
                      SfBadge(label: 'Bloque de estudio', tone: SfTone.info),
                    ],
                  ),
                  const _Section('Progreso'),
                  const SfProgressBar(value: 0.5),
                  const SizedBox(height: SfSpacing.md),
                  Row(
                    children: [
                      SfProgressRing(
                        value: 4.1 / 5,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('4.1', style: SfTypography.h1),
                            Text('de 5.0', style: SfTypography.caption),
                          ],
                        ),
                      ),
                      const SizedBox(width: SfSpacing.md),
                      const SfAvatar(name: 'Santiago'),
                    ],
                  ),
                  const _Section('Hojas inferiores'),
                  SfButton(
                    label: 'Abrir hoja de resultado',
                    variant: SfButtonVariant.secondary,
                    onPressed: () => showSfBottomSheet<void>(
                      context,
                      builder: (sheetContext) => SfResultSheet(
                        title: 'Tarea completada',
                        message: 'Taller 3 quedó marcada como entregada.',
                        primaryLabel: 'Listo',
                        onPrimary: () => Navigator.pop(sheetContext),
                        secondaryLabel: 'Deshacer',
                      ),
                    ),
                  ),
                  const _Section('Estados'),
                  const SfCard(
                    child: SfEmptyState(
                      icon: Icons.task_alt,
                      title: 'Aún no tienes tareas',
                      message: 'Agrega la primera y te avisamos antes de que venza.',
                    ),
                  ),
                  const SizedBox(height: SfSpacing.sm),
                  const SizedBox(height: 140, child: SfCard(child: SfLoadingState(message: 'Cargando tus tareas...'))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SfSpacing.xl, bottom: SfSpacing.sm),
      child: Text(title, style: SfTypography.h2),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches();

  static const _colors = <(String, Color)>[
    ('background', SfColors.background),
    ('surface', SfColors.surface),
    ('primarySoft', SfColors.primarySoft),
    ('border', SfColors.border),
    ('primary', SfColors.primary),
    ('primaryLight', SfColors.primaryLight),
    ('textSecondary', SfColors.textSecondary),
    ('success', SfColors.success),
    ('warning', SfColors.warning),
    ('danger', SfColors.danger),
    ('info', SfColors.info),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SfSpacing.xs,
      runSpacing: SfSpacing.xs,
      children: [
        for (final (name, color) in _colors)
          SizedBox(
            width: 104,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(SfRadius.sm),
                    border: Border.all(color: SfColors.border),
                  ),
                ),
                const SizedBox(height: 4),
                Text(name, style: SfTypography.caption),
              ],
            ),
          ),
      ],
    );
  }
}
