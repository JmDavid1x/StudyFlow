import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/di/inyeccion.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/features/subscription/ui/bloc/payment_cubit.dart';
import 'package:studyflow/features/subscription/ui/bloc/plus_cubit.dart';
import 'package:studyflow/features/subscription/ui/screens/payment_screen.dart';
import 'package:studyflow/features/subscription/ui/screens/plus_screen.dart';

/// Rutas de StudyFlow Plus (Santiago). Los Cubits los da GetIt
/// (subscription_di.dart).
final Map<String, WidgetBuilder> subscriptionRoutes = {
  AppRoutes.plus: (_) => BlocProvider(
    create: (_) => sl<PlusCubit>()..cargar(),
    child: const PlusScreen(),
  ),
  // Recibe la periodicidad elegida en Plus; si se abre directo, mensual.
  AppRoutes.payment: (context) {
    final argumento = ModalRoute.of(context)?.settings.arguments;
    return BlocProvider(
      create: (_) => sl<PaymentCubit>(
        param1: argumento is Periodicidad ? argumento : Periodicidad.mensual,
      ),
      child: const PaymentScreen(),
    );
  },
};
