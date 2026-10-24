import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/components/sf_button.dart';
import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_spacing.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

/// Estado vacío: dice por qué está vacío y qué hacer para llenarlo.
/// Ejemplo: "Aún no tienes tareas" + "Agrega tu primera tarea".
class SfEmptyState extends StatelessWidget {
  const SfEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SfSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: SfColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: SfColors.primaryLight),
          ),
          const SizedBox(height: SfSpacing.md),
          Text(title, textAlign: TextAlign.center, style: SfTypography.h2),
          const SizedBox(height: SfSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: SfTypography.body.copyWith(color: SfColors.textSecondary),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: SfSpacing.lg),
            SfButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

/// Estado de carga: dice qué se está cargando.
class SfLoadingState extends StatelessWidget {
  const SfLoadingState({super.key, required this.message});

  /// "Cargando tus tareas..."
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: SfColors.primaryLight),
          const SizedBox(height: SfSpacing.md),
          Text(message, style: SfTypography.body.copyWith(color: SfColors.textSecondary)),
        ],
      ),
    );
  }
}

/// Estado de error: dice qué falló y cómo reintentar.
class SfErrorState extends StatelessWidget {
  const SfErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SfEmptyState(
      icon: Icons.wifi_off_rounded,
      title: 'Algo salió mal',
      message: message,
      actionLabel: onRetry == null ? null : 'Reintentar',
      onAction: onRetry,
    );
  }
}
