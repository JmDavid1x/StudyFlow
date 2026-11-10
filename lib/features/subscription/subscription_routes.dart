import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/supabase/supabase_x.dart';
import 'package:studyflow/features/profile/data/profile_repository_impl.dart';
import 'package:studyflow/features/subscription/data/subscription_repository_impl.dart';
import 'package:studyflow/features/subscription/ui/bloc/payment_cubit.dart';
import 'package:studyflow/features/subscription/ui/bloc/plus_cubit.dart';
import 'package:studyflow/features/subscription/ui/screens/payment_screen.dart';
import 'package:studyflow/features/subscription/ui/screens/plus_screen.dart';

/// Rutas de StudyFlow Plus (Santiago). Los Cubits se crean aquí, con los
/// repositorios de Supabase.
final Map<String, WidgetBuilder> subscriptionRoutes = {
  AppRoutes.plus: (_) => BlocProvider(
    create: (_) => PlusCubit(
      ProfileRepositoryImpl(supabase),
      SubscriptionRepositoryImpl(supabase),
    )..cargar(),
    child: const PlusScreen(),
  ),
  // Recibe la periodicidad elegida en Plus; si se abre directo, mensual.
  AppRoutes.payment: (context) {
    final argumento = ModalRoute.of(context)?.settings.arguments;
    return BlocProvider(
      create: (_) => PaymentCubit(
        SubscriptionRepositoryImpl(supabase),
        periodicidad: argumento is Periodicidad
            ? argumento
            : Periodicidad.mensual,
      ),
      child: const PaymentScreen(),
    );
  },
};
