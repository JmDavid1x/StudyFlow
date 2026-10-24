import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_radius.dart';
import 'package:studyflow/core/design_system/tokens/sf_spacing.dart';

/// Tarjeta base. Plana a propósito: el borde separa, no la sombra.
class SfCard extends StatelessWidget {
  const SfCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(SfSpacing.md),
    this.highlighted = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Borde y fondo violeta: para lo que el usuario debe mirar primero
  /// (el plan de hoy, la opción elegida).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SfRadius.lg);
    return Material(
      color: highlighted ? SfColors.primarySoft : SfColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: highlighted ? SfColors.primary : SfColors.border,
              width: highlighted ? 1.5 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
