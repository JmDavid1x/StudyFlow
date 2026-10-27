import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/subjects/ui/widgets/component_selector.dart';
import 'package:studyflow/features/subjects/ui/widgets/grade_stepper.dart';
import 'package:studyflow/features/subjects/ui/widgets/subjects_prototype_data.dart';

/// Registrar nota (Figma 23). Al guardar abre la hoja S3 "Nota registrada".
///
/// Todo se elige con toques: actividad, componente y nota. El estado es solo
/// de interfaz; en el Sprint 2 se guarda en Supabase.
class RegisterGradeScreen extends StatefulWidget {
  const RegisterGradeScreen({super.key});

  @override
  State<RegisterGradeScreen> createState() => _RegisterGradeScreenState();
}

class _RegisterGradeScreenState extends State<RegisterGradeScreen> {
  int _activity = 0;
  int _component = 0;
  int _tenths = 46;

  @override
  void initState() {
    super.initState();
    _component = _componentOf(_activity);
  }

  /// Posición del componente al que pertenece la actividad.
  int _componentOf(int activity) {
    final index = prototypeComponents.indexWhere(
      (component) => component.name == prototypeActivities[activity].component,
    );
    return index == -1 ? 0 : index;
  }

  void _selectActivity(int activity) {
    setState(() {
      _activity = activity;
      _component = _componentOf(activity);
    });
  }

  Future<void> _save() async {
    final subject = subjectFromArguments(ModalRoute.of(context)?.settings.arguments);
    await showSfBottomSheet<void>(
      context,
      builder: (sheetContext) => SfResultSheet(
        title: 'Nota registrada',
        message: 'Tu nota acumulada en ${subject.name} subió de 4.1 a 4.2.',
        primaryLabel: 'Listo',
        onPrimary: () => Navigator.pop(sheetContext),
      ),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final subject = subjectFromArguments(ModalRoute.of(context)?.settings.arguments);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Registrar nota', useCloseIcon: true),
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
                    Text(
                      subject.name,
                      style: SfTypography.label.copyWith(color: SfColors.primaryLight),
                    ),
                    const SizedBox(height: SfSpacing.sm),
                    Text('Actividad', style: SfTypography.label),
                    const SizedBox(height: SfSpacing.xs),
                    SfOptionCards<int>(
                      columns: 1,
                      selected: _activity,
                      onChanged: _selectActivity,
                      options: [
                        for (var i = 0; i < prototypeActivities.length; i++)
                          SfOption<int>(
                            value: i,
                            label: prototypeActivities[i].title,
                            subtitle: prototypeActivities[i].detail,
                          ),
                      ],
                    ),
                    const SizedBox(height: SfSpacing.md),
                    Text('Componente', style: SfTypography.label),
                    const SizedBox(height: SfSpacing.xs),
                    ComponentSelector(
                      components: prototypeComponents,
                      selected: _component,
                      onChanged: (index) => setState(() => _component = index),
                    ),
                    const SizedBox(height: SfSpacing.md),
                    Text('Nota obtenida', style: SfTypography.label),
                    const SizedBox(height: SfSpacing.xs),
                    GradeStepper(
                      tenths: _tenths,
                      onChanged: (value) => setState(() => _tenths = value),
                    ),
                    const SizedBox(height: SfSpacing.xs),
                    Text('Escala de 0.0 a 5.0', style: SfTypography.caption),
                    const SizedBox(height: SfSpacing.md),
                    _AccumulatedPreview(goal: subject.goal),
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
              child: SfButton(label: 'Guardar nota', onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Así queda tu nota acumulada": cifras fijas del prototipo (4.1 a 4.2).
class _AccumulatedPreview extends StatelessWidget {
  const _AccumulatedPreview({required this.goal});

  final double goal;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Así queda tu nota acumulada',
            style: SfTypography.label.copyWith(color: SfColors.primaryLight),
          ),
          const SizedBox(height: SfSpacing.xs),
          Row(
            children: [
              Text(
                '4.1',
                style: SfTypography.h1.copyWith(color: SfColors.textSecondary),
              ),
              const SizedBox(width: SfSpacing.sm),
              const Icon(
                Icons.arrow_forward_rounded,
                size: SfSpacing.md,
                color: SfColors.textSecondary,
              ),
              const SizedBox(width: SfSpacing.sm),
              Text('4.2', style: SfTypography.h1),
            ],
          ),
          const SizedBox(height: SfSpacing.xs),
          Text(
            'Con el 65 % evaluado. Necesitarías 4.7 en el 35 % que falta para '
            'tu meta de ${goal.toStringAsFixed(1)}.',
            style: SfTypography.body,
          ),
        ],
      ),
    );
  }
}
