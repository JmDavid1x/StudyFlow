-- StudyFlow · Datos de ejemplo para desarrollar y para la demo.
-- Crea, para el usuario con sesión, el mismo semestre del prototipo de Figma:
-- 3 materias con horarios y componentes, tareas, un examen, una nota,
-- bloques de estudio y notificaciones. Las fechas son relativas a hoy.
--
-- Se llama desde la app: supabase.rpc('cargar_datos_ejemplo').
-- security invoker: inserta con los permisos del usuario, así el RLS aplica.
-- Si el usuario ya tiene un periodo activo, no hace nada.

create or replace function public.cargar_datos_ejemplo()
returns void
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_perfil uuid := (select auth.uid());
  v_hoy date := (now() at time zone 'America/Bogota')::date;
  v_periodo uuid;
  v_moviles uuid;
  v_calculo uuid;
  v_bases uuid;
  c_mov_talleres uuid;
  c_mov_proyecto uuid;
  c_mov_parciales uuid;
  c_cal_quices uuid;
  c_cal_parciales uuid;
  c_bd_talleres uuid;
  c_bd_proyecto uuid;
  a_taller3 uuid;
  a_lectura uuid;
  a_prototipo uuid;
  a_parcial2 uuid;
  a_quiz uuid;
  a_taller2 uuid;
begin
  if v_perfil is null then
    raise exception 'Necesitas iniciar sesión';
  end if;
  if exists (select 1 from public.periodos where perfil_id = v_perfil and activo) then
    return;
  end if;

  insert into public.periodos (perfil_id, nombre, fecha_inicio, fecha_fin, meta_promedio)
  values (v_perfil, '2026-2', v_hoy - 100, v_hoy + 30, 4.3)
  returning id into v_periodo;

  -- Materias
  insert into public.materias (periodo_id, nombre, profesor, creditos, color, meta_nota)
  values (v_periodo, 'Aplicaciones Móviles', 'Andrés Ruiz', 3, '#A78BFA', 4.4) returning id into v_moviles;
  insert into public.materias (periodo_id, nombre, profesor, creditos, color, meta_nota)
  values (v_periodo, 'Cálculo Integral', 'Laura Méndez', 4, '#F59E0B', 4.0) returning id into v_calculo;
  insert into public.materias (periodo_id, nombre, profesor, creditos, color, meta_nota)
  values (v_periodo, 'Bases de Datos', 'Camilo Torres', 3, '#2DD4BF', 4.5) returning id into v_bases;

  insert into public.horarios_clase (materia_id, dia_semana, hora_inicio, hora_fin, salon) values
    (v_moviles, 2, '07:00', '09:00', '401C'),
    (v_moviles, 4, '07:00', '09:00', '401C'),
    (v_calculo, 1, '09:00', '11:00', '302'),
    (v_calculo, 3, '09:00', '11:00', '302'),
    (v_bases, 5, '14:00', '16:00', 'Lab 2');

  -- Componentes (suman 100 por materia)
  insert into public.componentes_nota (materia_id, nombre, porcentaje) values (v_moviles, 'Talleres', 30) returning id into c_mov_talleres;
  insert into public.componentes_nota (materia_id, nombre, porcentaje) values (v_moviles, 'Proyecto', 40) returning id into c_mov_proyecto;
  insert into public.componentes_nota (materia_id, nombre, porcentaje) values (v_moviles, 'Parciales', 30) returning id into c_mov_parciales;
  insert into public.componentes_nota (materia_id, nombre, porcentaje) values (v_calculo, 'Quices', 40) returning id into c_cal_quices;
  insert into public.componentes_nota (materia_id, nombre, porcentaje) values (v_calculo, 'Parciales', 60) returning id into c_cal_parciales;
  insert into public.componentes_nota (materia_id, nombre, porcentaje) values (v_bases, 'Talleres', 50) returning id into c_bd_talleres;
  insert into public.componentes_nota (materia_id, nombre, porcentaje) values (v_bases, 'Proyecto', 50) returning id into c_bd_proyecto;

  -- Actividades
  insert into public.actividades (componente_id, titulo, tipo, fecha_limite, canal_entrega, porcentaje, prioridad, estado)
  values (c_bd_talleres, 'Taller 3: consultas SQL', 'tarea', (v_hoy + time '23:59') at time zone 'America/Bogota', 'intu', 15, 'alta', 'por_hacer')
  returning id into a_taller3;
  insert into public.actividades (componente_id, titulo, tipo, fecha_limite, canal_entrega, porcentaje, prioridad, estado)
  values (c_cal_quices, 'Lectura capítulo 4', 'tarea', (v_hoy + time '18:00') at time zone 'America/Bogota', 'en_clase', 0, 'media', 'por_hacer')
  returning id into a_lectura;
  insert into public.actividades (componente_id, titulo, tipo, fecha_limite, canal_entrega, porcentaje, prioridad, estado, notas)
  values (c_mov_proyecto, 'Prototipo flujo principal', 'proyecto', (v_hoy + 2 + time '23:59') at time zone 'America/Bogota', 'intu', 20, 'alta', 'en_progreso', 'Incluir el flujo de pago')
  returning id into a_prototipo;
  insert into public.actividades (componente_id, titulo, tipo, fecha_limite, lugar, porcentaje, prioridad, estado)
  values (c_cal_parciales, 'Parcial 2', 'examen', (v_hoy + 3 + time '09:00') at time zone 'America/Bogota', 'Salón 302', 30, 'alta', 'pendiente')
  returning id into a_parcial2;
  insert into public.actividades (componente_id, titulo, tipo, fecha_limite, canal_entrega, porcentaje, prioridad, estado)
  values (c_mov_talleres, 'Quiz 3: widgets', 'tarea', (v_hoy - 1 + time '23:59') at time zone 'America/Bogota', 'intu', 10, 'media', 'por_hacer')
  returning id into a_quiz;
  insert into public.actividades (componente_id, titulo, tipo, fecha_limite, canal_entrega, porcentaje, prioridad, estado, completada_en)
  values (c_bd_talleres, 'Taller 2: modelo relacional', 'tarea', (v_hoy - 6 + time '23:59') at time zone 'America/Bogota', 'intu', 15, 'media', 'completada', now() - interval '6 days')
  returning id into a_taller2;
  insert into public.actividades (componente_id, titulo, tipo, fecha_limite, canal_entrega, porcentaje, prioridad, estado)
  values
    (c_bd_proyecto, 'Entrega 1 del proyecto', 'proyecto', (v_hoy + 6 + time '23:59') at time zone 'America/Bogota', 'correo', 25, 'media', 'por_hacer'),
    (c_mov_talleres, 'Taller 4: navegación', 'tarea', (v_hoy + 9 + time '23:59') at time zone 'America/Bogota', 'intu', 10, 'baja', 'por_hacer');

  -- Nota registrada (Taller 2 = 4.3)
  insert into public.calificaciones (actividad_id, nota) values (a_taller2, 4.3);

  -- Bloques de estudio del usuario (hoy y mañana)
  insert into public.bloques_estudio (actividad_id, inicio, fin, estado, aviso_min) values
    (a_taller3, (v_hoy + time '13:00') at time zone 'America/Bogota', (v_hoy + time '15:00') at time zone 'America/Bogota', 'pendiente', 15),
    (a_lectura, (v_hoy + time '16:00') at time zone 'America/Bogota', (v_hoy + time '17:00') at time zone 'America/Bogota', 'pendiente', 15),
    (a_parcial2, (v_hoy + 1 + time '15:00') at time zone 'America/Bogota', (v_hoy + 1 + time '17:00') at time zone 'America/Bogota', 'pendiente', 15),
    (a_prototipo, (v_hoy - 1 + time '19:00') at time zone 'America/Bogota', (v_hoy - 1 + time '21:00') at time zone 'America/Bogota', 'pendiente', 15);

  -- Notificaciones
  insert into public.notificaciones (perfil_id, actividad_id, tipo, titulo, cuerpo, programada_para, enviada_en) values
    (v_perfil, a_taller3, 'entrega_hoy', 'Hoy vence: Taller 3: consultas SQL', 'Se entrega por INTU · 11:59 p. m.', now() - interval '2 hours', now() - interval '2 hours'),
    (v_perfil, a_prototipo, 'entrega_manana', 'Pronto vence: Prototipo flujo principal', 'Se entrega por INTU en 2 días', now() - interval '1 day', now() - interval '1 day'),
    (v_perfil, a_quiz, 'tarea_vencida', 'Venció: Quiz 3: widgets', '¿La entregaste? Márcala para llevar la cuenta', now() - interval '10 hours', now() - interval '10 hours');

  -- Termina la configuración inicial
  update public.perfiles set configuracion_completa = true where id = v_perfil;
  update public.ajustes_notificacion set push_activas = true where perfil_id = v_perfil;
end;
$$;

revoke execute on function public.cargar_datos_ejemplo() from public, anon;
grant execute on function public.cargar_datos_ejemplo() to authenticated;
