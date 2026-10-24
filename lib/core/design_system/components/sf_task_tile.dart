import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/components/sf_card.dart';
import 'package:studyflow/core/design_system/tokens/sf_colors.dart';
import 'package:studyflow/core/design_system/tokens/sf_spacing.dart';
import 'package:studyflow/core/design_system/tokens/sf_typography.dart';

/// Círculo para marcar una actividad como hecha. Su borde lleva el color de
/// la materia, así se reconoce la materia sin leer.
class SfCheckCircle extends StatelessWidget {
  const SfCheckCircle({
    super.key,
    required this.checked,
    required this.color,
    this.onTap,
  });

  final bool checked;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      button: onTap != null,
      label: checked ? 'Completada' : 'Marcar como completada',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? SfColors.success : Colors.transparent,
                border: checked ? null : Border.all(color: color, width: 2.2),
              ),
              child: checked
                  ? const Icon(Icons.check_rounded, size: 18, color: SfColors.background)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de una actividad (tarea, proyecto o examen) en Inicio, Tareas y Materia.
class SfTaskTile extends StatelessWidget {
  const SfTaskTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.subjectColor,
    this.done = false,
    this.trailing,
    this.onTap,
    this.onToggle,
  });

  final String title;

  /// "Bases de Datos · hoy 11:59 p. m."
  final String subtitle;
  final Color subjectColor;
  final bool done;

  /// Normalmente una [SfBadge] de prioridad o estado.
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(6, 10, SfSpacing.md, 10),
      child: Row(
        children: [
          SfCheckCircle(checked: done, color: subjectColor, onTap: onToggle),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SfTypography.bodyStrong.copyWith(
                    fontSize: 16,
                    color: done ? SfColors.textSecondary : SfColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: subjectColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: SfTypography.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: SfSpacing.xs),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Tarjeta de un dato corto en Inicio: "4 entregas esta semana".
class SfStatCard extends StatelessWidget {
  const SfStatCard({super.key, required this.value, required this.caption});

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: SfTypography.h1.copyWith(fontSize: 24)),
          const SizedBox(height: 2),
          Text(caption, style: SfTypography.caption),
        ],
      ),
    );
  }
}

/// Avatar con la inicial del nombre (no se inventan fotos de perfil).
class SfAvatar extends StatelessWidget {
  const SfAvatar({super.key, required this.name, this.size = 72});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: SfColors.primary, shape: BoxShape.circle),
      child: Text(
        initial,
        style: SfTypography.h1.copyWith(fontSize: size * 0.42),
      ),
    );
  }
}
