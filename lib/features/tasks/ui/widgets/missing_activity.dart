import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';

/// Se ve si se abre un detalle sin una Actividad como argumento (por ejemplo,
/// desde una pantalla que todavía usa datos de ejemplo).
class MissingActivity extends StatelessWidget {
  const MissingActivity({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SfScreenHeader(title: title),
            const Padding(
              padding: EdgeInsets.all(SfSpacing.screen),
              child: SfCard(
                child: SfEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No encontramos esta actividad',
                  message: 'Vuelve a tus tareas y ábrela desde la lista.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
