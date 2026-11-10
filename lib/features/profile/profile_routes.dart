import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/profile/data/profile_repository_impl.dart';
import 'package:studyflow/features/profile/ui/bloc/notification_settings_cubit.dart';
import 'package:studyflow/features/profile/ui/screens/notification_settings_screen.dart';

/// Rutas de Perfil (Santiago). La pestaña Perfil no es ruta: la crea
/// MainShell y su Cubit vive dentro de ProfileScreen.
final Map<String, WidgetBuilder> profileRoutes = {
  AppRoutes.notificationSettings: (_) => BlocProvider(
    create: (_) =>
        NotificationSettingsCubit(ProfileRepositoryImpl(supabase))..cargar(),
    child: const NotificationSettingsScreen(),
  ),
};
