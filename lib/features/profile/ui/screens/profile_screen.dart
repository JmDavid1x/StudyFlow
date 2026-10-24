import 'package:flutter/material.dart';

import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';

/// Pestaña Perfil (Figma 25). La construye Persona 5.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(figma: '25', title: 'Perfil', owner: Team.p5);
  }
}
