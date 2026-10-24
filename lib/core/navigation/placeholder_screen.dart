import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/core/navigation/app_routes.dart';

/// Pantalla temporal mientras su dueño la construye. Cuando la pantalla real
/// esté lista, se cambia en el archivo de rutas de su feature.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.figma,
    required this.title,
    required this.owner,
    this.showBack = true,
  });

  final String figma;
  final String title;
  final String owner;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SfScreenHeader(title: title, showBack: showBack),
            Expanded(child: Center(child: PlaceholderBody(figma: figma, owner: owner))),
          ],
        ),
      ),
    );
  }
}

/// Contenido de una pestaña que aún no se construye.
class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({
    super.key,
    required this.figma,
    required this.title,
    required this.owner,
  });

  final String figma;
  final String title;
  final String owner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SfLargeTitle(title: title),
            Expanded(child: Center(child: PlaceholderBody(figma: figma, owner: owner))),
          ],
        ),
      ),
    );
  }
}

class PlaceholderBody extends StatelessWidget {
  const PlaceholderBody({super.key, required this.figma, required this.owner});

  final String figma;
  final String owner;

  @override
  Widget build(BuildContext context) {
    // TODO(sprint-1): cada dueño reemplaza esta pantalla por la real.
    return SingleChildScrollView(
      child: SfEmptyState(
        icon: Icons.construction_outlined,
        title: 'Pantalla $figma en construcción',
        message: 'La construye $owner. Mírala en Figma y ármala con los componentes del design system.',
        actionLabel: 'Ver todas las pantallas',
        onAction: () => Navigator.pushNamed(context, AppRoutes.devMenu),
      ),
    );
  }
}
