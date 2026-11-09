import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/tasks/domain/textos_actividad.dart';

/// Ícono y color de cada tipo de aviso, como en Figma 13. [filled] = ícono
/// sobre el color sólido; si no, sobre el color suave.
({IconData icon, Color color, bool filled}) notificationStyle(TipoNotificacion tipo) => switch (tipo) {
  TipoNotificacion.entregaManana => (icon: Icons.alarm_rounded, color: SfColors.primaryLight, filled: false),
  TipoNotificacion.entregaHoy => (icon: Icons.alarm_rounded, color: SfColors.warning, filled: false),
  TipoNotificacion.tareaVencida => (icon: Icons.warning_amber_rounded, color: SfColors.danger, filled: false),
  TipoNotificacion.tareaCompletada => (icon: Icons.check_rounded, color: SfColors.success, filled: true),
  TipoNotificacion.bloquePorEmpezar => (icon: Icons.schedule_rounded, color: SfColors.primaryLight, filled: false),
  TipoNotificacion.bloquePendiente => (icon: Icons.schedule_rounded, color: SfColors.warning, filled: false),
  TipoNotificacion.planDelDia => (icon: Icons.smart_toy_outlined, color: SfColors.primary, filled: true),
  TipoNotificacion.resumenSemanal => (icon: Icons.insights_rounded, color: SfColors.primaryLight, filled: false),
};

/// Fila de un aviso (Figma 13). Los no leídos se destacan en violeta y
/// llevan un punto a la derecha.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, required this.onTap});

  final Notificacion notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = notificationStyle(notification.tipo);
    final color = style.color;
    final unread = !notification.leida;
    final iconSize = SfSpacing.xl + SfSpacing.xs;
    return SfCard(
      highlighted: unread,
      onTap: onTap,
      padding: const EdgeInsets.all(SfSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: style.filled ? color : color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              style.icon,
              size: SfSpacing.lg - SfSpacing.xxs,
              color: style.filled
                  ? (color == SfColors.primary ? SfColors.textPrimary : SfColors.background)
                  : color,
            ),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.titulo, style: SfTypography.bodyStrong),
                const SizedBox(height: SfSpacing.xxs),
                Text(notification.cuerpo, style: SfTypography.caption),
              ],
            ),
          ),
          const SizedBox(width: SfSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(hora(notification.programadaPara), style: SfTypography.caption),
              if (unread) ...[
                const SizedBox(height: SfSpacing.xs),
                Container(
                  width: SfSpacing.xs,
                  height: SfSpacing.xs,
                  decoration: const BoxDecoration(color: SfColors.primaryLight, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
