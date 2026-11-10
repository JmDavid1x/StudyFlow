import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/assistant/data/assistant_repository_impl.dart';
import 'package:studyflow/features/assistant/ui/bloc/assistant_bloc.dart';
import 'package:studyflow/features/assistant/ui/screens/assistant_screen.dart';
import 'package:studyflow/features/subscription/data/subscription_repository_impl.dart';

/// Rutas de Asistente (Santiago). El Bloc se crea aquí, con los repositorios
/// de Supabase.
final Map<String, WidgetBuilder> assistantRoutes = {
  AppRoutes.assistant: (_) => BlocProvider(
    create: (_) => AssistantBloc(
      AssistantRepositoryImpl(supabase),
      SubscriptionRepositoryImpl(supabase),
    )..add(const AsistenteIniciado()),
    child: const AssistantScreen(),
  ),
};
