import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/components/sf_icon_button.dart';
import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_spacing.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

/// Barra superior de las pantallas internas: botón atrás, título centrado y
/// una acción opcional a la derecha.
class SfScreenHeader extends StatelessWidget {
  const SfScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = true,
    this.useCloseIcon = false,
    this.trailing,
  });

  final String title;

  /// Por defecto vuelve a la pantalla anterior.
  final VoidCallback? onBack;
  final bool showBack;

  /// X en lugar de flecha: para flujos que se cancelan (nueva tarea, pago).
  final bool useCloseIcon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.xs),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            if (showBack)
              SfIconButton(
                icon: useCloseIcon ? Icons.close : Icons.chevron_left,
                tooltip: useCloseIcon ? 'Cerrar' : 'Atrás',
                onPressed: onBack ?? () => Navigator.maybePop(context),
              )
            else
              const SizedBox(width: 44),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: SfTypography.title,
              ),
            ),
            trailing ?? const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }
}

/// Título grande de una pestaña: "Calendario", "Tareas", "Materias".
class SfLargeTitle extends StatelessWidget {
  const SfLargeTitle({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.md, SfSpacing.screen, SfSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: SfTypography.display)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Encabezado de sección con una acción opcional: "Prioridades de hoy · Ver todas".
class SfSectionHeader extends StatelessWidget {
  const SfSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: SfTypography.h2)),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: SfColors.primaryLight,
              minimumSize: const Size(44, 44),
            ),
            child: Text(
              actionLabel!,
              style: SfTypography.bodyStrong.copyWith(color: SfColors.primaryLight),
            ),
          ),
      ],
    );
  }
}
