import 'package:studyflow/core/demo/demo_data.dart';

/// Datos de la cuenta para el Sprint 1. El nombre sale de DemoData; correo y
/// universidad no están ahí, así que viven aquí hasta el Sprint 2, cuando
/// salen de la sesión de Supabase.
abstract final class ProfileDemo {
  static const name = DemoData.studentName;
  static const email = 'santiago@u.icesi.edu.co';
  static const university = 'Universidad Icesi';
  static const plan = 'Plan gratis';
}
