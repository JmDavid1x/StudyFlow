import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/calendar/ui/screens/calendar_screen.dart';
import 'package:studyflow/features/home/ui/screens/home_screen.dart';
import 'package:studyflow/features/profile/ui/screens/profile_screen.dart';
import 'package:studyflow/features/subjects/ui/screens/subjects_screen.dart';
import 'package:studyflow/features/tasks/ui/screens/tasks_screen.dart';

/// Contenedor de las cinco pestañas con la barra inferior.
///
/// IndexedStack conserva el estado de cada pestaña (el scroll, el filtro
/// elegido) al cambiar entre ellas.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialTab.clamp(0, _tabs.length - 1).toInt();

  static const _tabs = <Widget>[
    HomeScreen(),
    CalendarScreen(),
    TasksScreen(),
    SubjectsScreen(),
    ProfileScreen(),
  ];

  static const _items = <SfNavItem>[
    SfNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Inicio'),
    SfNavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Calendario'),
    SfNavItem(icon: Icons.check_box_outlined, activeIcon: Icons.check_box, label: 'Tareas'),
    SfNavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book, label: 'Materias'),
    SfNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: SfBottomNav(
        items: _items,
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
      ),
    );
  }
}
