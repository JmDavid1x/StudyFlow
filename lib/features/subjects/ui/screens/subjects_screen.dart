import 'package:flutter/material.dart';

import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';

/// Pestaña Materias (Figma 21). La construye Persona 2.
class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(figma: '21', title: 'Materias', owner: Team.p2);
  }
}
