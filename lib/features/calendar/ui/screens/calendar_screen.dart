import 'package:flutter/material.dart';

import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';

/// Pestaña Calendario (Figma 20). La construye Camilo.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(figma: '20', title: 'Calendario', owner: Team.p4);
  }
}
