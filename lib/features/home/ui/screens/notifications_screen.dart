import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/home/ui/widgets/demo_notifications.dart';
import 'package:studyflow/features/home/ui/widgets/notification_tile.dart';

/// Notificaciones (Figma 13): avisos agrupados por día. Tocar un aviso lo
/// marca como leído y abre lo que menciona; deslizarlo lo quita.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// Solo interfaz: en el Sprint 2 esto se guarda en Supabase.
  final Set<String> _read = {};
  final Set<String> _removed = {};

  void _open(DemoNotification notification) {
    setState(() => _read.add(notification.id));
    final route = notification.route;
    if (route != null) Navigator.pushNamed(context, route, arguments: notification.task);
  }

  @override
  Widget build(BuildContext context) {
    final visible = DemoNotifications.all.where((n) => !_removed.contains(n.id)).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Notificaciones'),
            Expanded(
              child: visible.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: SfEmptyState(
                          icon: Icons.notifications_none_rounded,
                          title: 'Estás al día',
                          message: 'Aquí te avisamos cuando algo esté por vencer o tu plan del día esté listo.',
                          actionLabel: 'Volver al inicio',
                          onAction: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.main,
                            (_) => false,
                            arguments: AppTabs.home,
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(SfSpacing.screen, 0, SfSpacing.screen, SfSpacing.lg),
                      children: [
                        for (final day in DemoNotifications.days)
                          if (visible.any((n) => n.day == day)) ...[
                            const SizedBox(height: SfSpacing.xs),
                            Text(day, style: SfTypography.label),
                            const SizedBox(height: SfSpacing.xs),
                            for (final notification in visible.where((n) => n.day == day))
                              Padding(
                                padding: const EdgeInsets.only(bottom: SfSpacing.sm),
                                child: Dismissible(
                                  key: ValueKey(notification.id),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) => setState(() => _removed.add(notification.id)),
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: SfSpacing.lg),
                                    child: const Icon(Icons.delete_outline_rounded, color: SfColors.danger),
                                  ),
                                  child: NotificationTile(
                                    notification: notification,
                                    unread: notification.unread && !_read.contains(notification.id),
                                    onTap: () => _open(notification),
                                  ),
                                ),
                              ),
                          ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
