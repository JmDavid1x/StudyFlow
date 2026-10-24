import 'package:flutter/material.dart';

import 'package:studyflow/core/design_system/gallery/design_system_gallery.dart';
import 'package:studyflow/core/dev/dev_menu_screen.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/main_shell.dart';
import 'package:studyflow/core/navigation/placeholder_screen.dart';
import 'package:studyflow/features/assistant/assistant_routes.dart';
import 'package:studyflow/features/auth/auth_routes.dart';
import 'package:studyflow/features/profile/profile_routes.dart';
import 'package:studyflow/features/study_blocks/study_blocks_routes.dart';
import 'package:studyflow/features/subjects/subjects_routes.dart';
import 'package:studyflow/features/subscription/subscription_routes.dart';
import 'package:studyflow/features/task_form/task_form_routes.dart';
import 'package:studyflow/features/tasks/tasks_routes.dart';

/// Junta las rutas de todas las features. Cada feature declara las suyas en
/// su propio archivo `*_routes.dart`, así nadie edita este archivo en el sprint.
abstract final class AppRouter {
  static final Map<String, WidgetBuilder> routes = {
    ...authRoutes,
    AppRoutes.main: (context) {
      final tab = ModalRoute.of(context)?.settings.arguments;
      return MainShell(initialTab: tab is int ? tab : AppTabs.home);
    },
    ...subjectsRoutes,
    ...tasksRoutes,
    ...taskFormRoutes,
    ...studyBlocksRoutes,
    ...assistantRoutes,
    ...profileRoutes,
    ...subscriptionRoutes,
    AppRoutes.devMenu: (_) => const DevMenuScreen(),
    AppRoutes.designSystem: (_) => const DesignSystemGallery(),
  };

  static Route<void> unknown(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => PlaceholderScreen(
        figma: '?',
        title: 'Ruta no encontrada',
        owner: settings.name ?? 'nadie',
      ),
    );
  }
}
