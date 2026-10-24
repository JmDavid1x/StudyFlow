import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/screen_catalog.dart';

/// Índice de todas las pantallas, agrupadas por quién las construye. Solo
/// para desarrollo: permite abrir cualquier pantalla sin recorrer el flujo.
class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final owners = <String>[];
    for (final screen in screenCatalog) {
      if (!owners.contains(screen.owner)) owners.add(screen.owner);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Pantallas del Sprint 1'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(SfSpacing.screen, SfSpacing.xs, SfSpacing.screen, SfSpacing.xxl),
                children: [
                  SfButton(
                    label: 'Ver el design system',
                    icon: Icons.palette_outlined,
                    variant: SfButtonVariant.secondary,
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.designSystem),
                  ),
                  for (final owner in owners) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: SfSpacing.lg, bottom: SfSpacing.xs),
                      child: Text(owner, style: SfTypography.h2),
                    ),
                    for (final screen in screenCatalog.where((s) => s.owner == owner))
                      _ScreenRow(screen: screen),
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

class _ScreenRow extends StatelessWidget {
  const _ScreenRow({required this.screen});

  final ScreenInfo screen;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 72,
        child: Text(screen.figma, style: SfTypography.number.copyWith(color: SfColors.primaryLight)),
      ),
      title: Text(screen.title, style: SfTypography.body),
      trailing: const Icon(Icons.chevron_right, color: SfColors.textSecondary),
      onTap: () => Navigator.pushNamed(context, screen.route, arguments: screen.tab),
    );
  }
}
