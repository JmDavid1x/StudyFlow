import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:studyflow/app.dart';
import 'package:studyflow/core/supabase/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Conecta con Supabase antes de dibujar la app: la sesión guardada se
  // recupera aquí, así el Splash ya sabe si el usuario había iniciado sesión.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  runApp(const StudyFlowApp());
}
