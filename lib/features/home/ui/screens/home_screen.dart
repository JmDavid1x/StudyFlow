import 'package:flutter/material.dart';

import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';

/// Pestaña Inicio (Figma 11 · 12 · 16). La construye Persona 3.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(figma: '11 · 12 · 16', title: 'Inicio', owner: Team.p3);
  }
}
