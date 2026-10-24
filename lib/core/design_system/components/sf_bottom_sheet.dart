import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/components/sf_badge.dart';
import 'package:studyflow/core/design_system/components/sf_button.dart';
import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_radius.dart';
import 'package:studyflow/core/design_system/tokens/sf_spacing.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

/// Abre una hoja inferior con el estilo de StudyFlow (las pantallas S1 a S11
/// de Figma). Se cierra deslizando hacia abajo o tocando afuera.
Future<T?> showSfBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: SfColors.surfaceRaised,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(SfRadius.sheet)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, SfSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: SfColors.borderStrong,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              builder(sheetContext),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Contenido de una hoja de resultado: "Tarea completada", "Nota registrada",
/// "Plan agregado", "Prueba activada".
class SfResultSheet extends StatelessWidget {
  const SfResultSheet({
    super.key,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.icon = Icons.check_rounded,
    this.tone = SfTone.success,
    this.secondaryLabel,
    this.onSecondary,
    this.child,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final IconData icon;
  final SfTone tone;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Contenido extra entre el mensaje y los botones (por ejemplo, la lista
  /// de bloques del plan).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final color = tone.color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, size: 30, color: SfColors.background),
            ),
          ),
        ),
        const SizedBox(height: SfSpacing.sm),
        Text(title, textAlign: TextAlign.center, style: SfTypography.h1),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: SfTypography.body.copyWith(color: SfColors.textSecondary),
        ),
        if (child != null) ...[
          const SizedBox(height: SfSpacing.md),
          child!,
        ],
        const SizedBox(height: SfSpacing.lg),
        SfButton(label: primaryLabel, onPressed: onPrimary),
        if (secondaryLabel != null) ...[
          const SizedBox(height: SfSpacing.xxs),
          SfButton(
            label: secondaryLabel!,
            onPressed: onSecondary ?? () => Navigator.pop(context),
            variant: SfButtonVariant.ghost,
          ),
        ],
      ],
    );
  }
}
