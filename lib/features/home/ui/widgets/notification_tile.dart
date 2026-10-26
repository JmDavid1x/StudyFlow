import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/home/ui/widgets/demo_notifications.dart';

/// Fila de un aviso (Figma 13). Los no leídos se destacan en violeta y
/// llevan un punto a la derecha.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.unread,
    required this.onTap,
  });

  final DemoNotification notification;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = notification.color;
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
              color: notification.filled ? color : color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification.icon,
              size: SfSpacing.lg - SfSpacing.xxs,
              color: notification.filled
                  ? (color == SfColors.primary ? SfColors.textPrimary : SfColors.background)
                  : color,
            ),
          ),
          const SizedBox(width: SfSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: SfTypography.bodyStrong),
                const SizedBox(height: SfSpacing.xxs),
                Text(notification.message, style: SfTypography.caption),
              ],
            ),
          ),
          const SizedBox(width: SfSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(notification.time, style: SfTypography.caption),
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
