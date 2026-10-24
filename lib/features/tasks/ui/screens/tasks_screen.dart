import 'package:flutter/material.dart';

import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/core/navigation/team.dart';

/// Pestaña Tareas (Figma 17). La construye Perez.
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(figma: '17', title: 'Tareas', owner: Team.p3);
  }
}
