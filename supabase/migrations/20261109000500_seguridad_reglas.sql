-- StudyFlow · Ajustes de seguridad y reglas de negocio (revisión del domingo 8).
--
-- 1. Plus y pagos: el cliente solo LEE. La prueba gratis se pide con el RPC
--    iniciar_prueba(); el cobro real lo haría el servidor (webhook de la pasarela).
-- 2. Perfil: el usuario solo edita nombre, programa, semestre y configuración.
--    El correo se copia desde auth.users (nadie puede "apartar" el correo de otro).
-- 3. Registro: el trigger nunca rompe el signUp; la universidad sale del dominio.
-- 4. Notificaciones y planes no pueden apuntar a filas de otro usuario.
-- 5. Reglas: componentes ≤ 100 %, completada_en coherente con el estado y checks de rango.
-- 6. Defensa en profundidad: anon solo lee universidades; nadie puede TRUNCATE.
--
-- "Vencida": una sola fuente de verdad → la calcula la app (Actividad.estaVencida),
-- la base no cambia estados por fecha.

-- 1. Plus y pagos ---------------------------------------------------------------
drop policy "mis suscripciones" on public.suscripciones;
drop policy "mis pagos" on public.pagos;
create policy "ver mis suscripciones" on public.suscripciones
  for select to authenticated using (perfil_id = (select auth.uid()));
create policy "ver mis pagos" on public.pagos
  for select to authenticated using (privado.es_mi_suscripcion(suscripcion_id));
revoke insert, update, delete on public.suscripciones, public.pagos from anon, authenticated;

-- Prueba gratis de 7 días: crea la suscripción en_prueba y el pago pendiente
-- (se cobraría al terminar la prueba). El índice un_una_prueba impide una segunda.
create or replace function public.iniciar_prueba(p_periodicidad public.periodicidad, p_metodo public.metodo_pago)
returns public.suscripciones
language plpgsql security definer set search_path = '' as $$
declare
  v_perfil uuid := (select auth.uid());
  v_precio integer := case p_periodicidad when 'mensual' then 9900 else 39900 end;
  v_suscripcion public.suscripciones;
begin
  if v_perfil is null then
    raise exception 'Necesitas iniciar sesión' using errcode = '42501';
  end if;
  insert into public.suscripciones (perfil_id, periodicidad, precio_cop, estado, prueba_hasta, renovacion_automatica)
  values (v_perfil, p_periodicidad, v_precio, 'en_prueba', current_date + 7, true)
  returning * into v_suscripcion;
  insert into public.pagos (suscripcion_id, monto_cop, metodo, estado, referencia_pasarela)
  values (v_suscripcion.id, v_precio, p_metodo, 'pendiente', 'SIM-' || replace(gen_random_uuid()::text, '-', ''));
  return v_suscripcion;
end;
$$;
revoke execute on function public.iniciar_prueba(public.periodicidad, public.metodo_pago) from public, anon;
grant execute on function public.iniciar_prueba(public.periodicidad, public.metodo_pago) to authenticated;

-- 2. Perfil -----------------------------------------------------------------------
revoke update on public.perfiles from anon, authenticated;
grant update (nombre, programa, semestre, configuracion_completa) on public.perfiles to authenticated;

create or replace function privado.sincronizar_correo()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  update public.perfiles set correo = lower(new.email) where id = new.id;
  return new;
end;
$$;
create trigger al_cambiar_correo
  after update of email on auth.users
  for each row when (new.email is distinct from old.email)
  execute function privado.sincronizar_correo();

-- 3. Registro robusto -------------------------------------------------------------
-- Si el dominio no es de una universidad conocida, el perfil queda sin universidad
-- (la app ya exige correo institucional antes del signUp) en vez de romper el registro.
alter table public.perfiles alter column universidad_id drop not null;

create or replace function privado.crear_perfil()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_universidad uuid;
  v_meta text := nullif(trim(new.raw_user_meta_data ->> 'universidad_id'), '');
  v_dominio text := lower(split_part(coalesce(new.email, ''), '@', 2));
begin
  -- 1.º el dominio del correo (también subdominios: profe@x.u.icesi.edu.co)
  select u.id into v_universidad
  from public.universidades u
  where v_dominio = u.dominio_correo or v_dominio like '%.' || u.dominio_correo
  limit 1;
  -- 2.º la universidad que eligió en el registro, si es un id válido
  if v_universidad is null and v_meta ~* '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$' then
    select u.id into v_universidad from public.universidades u where u.id = v_meta::uuid;
  end if;

  insert into public.perfiles (id, universidad_id, nombre, correo)
  values (
    new.id,
    v_universidad,
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'nombre'), ''), nullif(split_part(new.email, '@', 1), ''), 'Estudiante'),
    coalesce(lower(new.email), new.id::text)
  )
  on conflict (id) do nothing;
  insert into public.ajustes_notificacion (perfil_id) values (new.id) on conflict do nothing;
  return new;
end;
$$;

-- 4. Referencias a filas ajenas ---------------------------------------------------
create or replace function privado.es_mi_bloque(p_bloque uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.bloques_estudio b
    where b.id = p_bloque and privado.es_mi_actividad(b.actividad_id)
  );
$$;

create or replace function privado.es_mi_mensaje(p_mensaje uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.mensajes_asistente m
    where m.id = p_mensaje and m.perfil_id = (select auth.uid())
  );
$$;
grant execute on function privado.es_mi_bloque(uuid), privado.es_mi_mensaje(uuid) to authenticated;

alter policy "mis notificaciones" on public.notificaciones
  with check (
    perfil_id = (select auth.uid())
    and (actividad_id is null or privado.es_mi_actividad(actividad_id))
    and (bloque_id is null or privado.es_mi_bloque(bloque_id))
  );
alter policy "mis planes" on public.planes_estudio
  with check (perfil_id = (select auth.uid()) and (mensaje_id is null or privado.es_mi_mensaje(mensaje_id)));

-- Un celular puede pasar de una cuenta a otra (token_push es único).
create or replace function public.registrar_dispositivo(p_token text, p_plataforma public.plataforma)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if (select auth.uid()) is null then
    raise exception 'Necesitas iniciar sesión' using errcode = '42501';
  end if;
  insert into public.dispositivos (perfil_id, token_push, plataforma)
  values ((select auth.uid()), p_token, p_plataforma)
  on conflict (token_push) do update
    set perfil_id = excluded.perfil_id, plataforma = excluded.plataforma, ultimo_uso = now();
end;
$$;
revoke execute on function public.registrar_dispositivo(text, public.plataforma) from public, anon;
grant execute on function public.registrar_dispositivo(text, public.plataforma) to authenticated;

-- 5. Reglas de negocio ------------------------------------------------------------
-- Los componentes de una materia no pueden sumar más de 100 %. Se revisa al final
-- de la transacción, para poder reemplazar varios componentes a la vez.
create or replace function privado.validar_componentes()
returns trigger language plpgsql set search_path = '' as $$
begin
  if (select sum(porcentaje) from public.componentes_nota where materia_id = new.materia_id) > 100 then
    raise exception 'Los componentes de la materia suman más de 100 %%' using errcode = '23514';
  end if;
  return new;
end;
$$;
create constraint trigger componentes_max_100
  after insert or update on public.componentes_nota
  deferrable initially deferred
  for each row execute function privado.validar_componentes();

-- completada_en solo existe si la actividad está completada o presentada.
create or replace function privado.sincronizar_completada()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.completada_en := case
    when new.estado in ('completada', 'presentado') then coalesce(new.completada_en, now())
  end;
  return new;
end;
$$;
create trigger actividades_completada
  before insert or update of estado, completada_en on public.actividades
  for each row execute function privado.sincronizar_completada();

alter table public.materias
  add constraint materias_color_hex check (color ~ '^#[0-9A-Fa-f]{6}$');
alter table public.perfiles
  add constraint perfiles_semestre check (semestre is null or semestre between 1 and 12);
alter table public.ajustes_notificacion
  add constraint ajustes_rangos check (
    dias_antes between 0 and 14 and horas_antes between 0 and 48 and minutos_antes_bloque between 0 and 240
  );
alter table public.bloques_estudio
  add constraint bloques_aviso check (aviso_min is null or aviso_min between 0 and 240),
  add constraint bloques_completado check ((estado = 'completado') = (completado_en is not null));
alter table public.pagos
  drop constraint pagos_check,
  add constraint pagos_pagado check ((estado in ('aprobado', 'reembolsado')) = (pagado_en is not null));

-- 6. Defensa en profundidad -------------------------------------------------------
revoke truncate on all tables in schema public from anon, authenticated;
revoke all on all tables in schema public from anon;
grant select on public.universidades to anon;
