import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/assistant/ui/bloc/assistant_bloc.dart';
import 'package:studyflow/features/assistant/ui/screens/assistant_screen.dart';

/// Rutas de Asistente (Santiago). El Bloc sale de GetIt (assistant_di.dart).
final Map<String, WidgetBuilder> assistantRoutes = {
  AppRoutes.assistant: (_) => BlocProvider(
    create: (_) => sl<AssistantBloc>()..add(const AsistenteIniciado()),
    child: const AssistantScreen(),
  ),
};
