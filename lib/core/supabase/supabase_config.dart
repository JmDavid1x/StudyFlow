/// Conexión con el proyecto de Supabase de StudyFlow.
///
/// La llave publicable está hecha para ir dentro de la app: no da acceso a
/// nada por sí sola. Lo que protege los datos son las reglas RLS de la base
/// (cada usuario solo ve sus filas), definidas en `supabase/migrations/`.
/// La llave secreta (service_role) nunca va en la app.
abstract final class SupabaseConfig {
  static const url = 'https://vgrnqvsrdojnpnxgqybe.supabase.co';
  static const publishableKey = 'sb_publishable_sXOJpqIgzzjb3qZCSn9yTA_utufO1eh';
}
