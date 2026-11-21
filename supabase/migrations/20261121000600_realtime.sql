-- StudyFlow · Cambios en vivo (Sprint 3).
-- Supabase Realtime solo avisa de las tablas que están en esta publicación.
-- El RLS sigue aplicando: cada usuario recibe solo los cambios de sus filas.
alter publication supabase_realtime add table
  public.actividades,
  public.calificaciones,
  public.bloques_estudio,
  public.materias,
  public.notificaciones;
