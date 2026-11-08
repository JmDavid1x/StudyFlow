-- StudyFlow · Seguridad (RLS) y triggers.
-- Regla: cada usuario solo lee y escribe sus propias filas. Las tablas que no
-- tienen perfil_id se validan subiendo por sus llaves foráneas hasta el perfil.

-- Esquema privado: estas funciones no quedan expuestas en la API.
create schema if not exists privado;
grant usage on schema privado to authenticated;

-- Funciones de pertenencia -----------------------------------------------------
-- security definer: consultan sin pasar otra vez por el RLS (más rápido y sin ciclos).
create or replace function privado.es_mi_periodo(p_periodo uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.periodos p
    where p.id = p_periodo and p.perfil_id = (select auth.uid())
  );
$$;

create or replace function privado.es_mi_materia(p_materia uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.materias m
    join public.periodos p on p.id = m.periodo_id
    where m.id = p_materia and p.perfil_id = (select auth.uid())
  );
$$;

create or replace function privado.es_mi_componente(p_componente uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.componentes_nota c
    join public.materias m on m.id = c.materia_id
    join public.periodos p on p.id = m.periodo_id
    where c.id = p_componente and p.perfil_id = (select auth.uid())
  );
$$;

create or replace function privado.es_mi_actividad(p_actividad uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.actividades a
    join public.componentes_nota c on c.id = a.componente_id
    join public.materias m on m.id = c.materia_id
    join public.periodos p on p.id = m.periodo_id
    where a.id = p_actividad and p.perfil_id = (select auth.uid())
  );
$$;

create or replace function privado.es_mi_plan(p_plan uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.planes_estudio pl
    where pl.id = p_plan and pl.perfil_id = (select auth.uid())
  );
$$;

create or replace function privado.es_mi_suscripcion(p_suscripcion uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.suscripciones s
    where s.id = p_suscripcion and s.perfil_id = (select auth.uid())
  );
$$;

grant execute on all functions in schema privado to authenticated;

-- Activar RLS en todas las tablas ---------------------------------------------
alter table public.universidades enable row level security;
alter table public.perfiles enable row level security;
alter table public.suscripciones enable row level security;
alter table public.pagos enable row level security;
alter table public.periodos enable row level security;
alter table public.materias enable row level security;
alter table public.horarios_clase enable row level security;
alter table public.componentes_nota enable row level security;
alter table public.actividades enable row level security;
alter table public.calificaciones enable row level security;
alter table public.mensajes_asistente enable row level security;
alter table public.planes_estudio enable row level security;
alter table public.plan_actividades enable row level security;
alter table public.bloques_estudio enable row level security;
alter table public.ajustes_notificacion enable row level security;
alter table public.notificaciones enable row level security;
alter table public.dispositivos enable row level security;

-- Políticas -------------------------------------------------------------------
-- Universidades: catálogo de solo lectura; el registro lo lee sin sesión.
create policy "leer universidades" on public.universidades
  for select to anon, authenticated using (true);

-- Perfil: lo crea el trigger; el usuario lo lee y lo edita.
create policy "ver mi perfil" on public.perfiles
  for select to authenticated using (id = (select auth.uid()));
create policy "editar mi perfil" on public.perfiles
  for update to authenticated using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- Ajustes: los crea el trigger; el usuario los lee y los edita.
create policy "ver mis ajustes" on public.ajustes_notificacion
  for select to authenticated using (perfil_id = (select auth.uid()));
create policy "editar mis ajustes" on public.ajustes_notificacion
  for update to authenticated using (perfil_id = (select auth.uid())) with check (perfil_id = (select auth.uid()));

-- Tablas con perfil_id directo: todo sobre las filas propias.
create policy "mis suscripciones" on public.suscripciones
  for all to authenticated using (perfil_id = (select auth.uid())) with check (perfil_id = (select auth.uid()));
create policy "mis periodos" on public.periodos
  for all to authenticated using (perfil_id = (select auth.uid())) with check (perfil_id = (select auth.uid()));
create policy "mis mensajes" on public.mensajes_asistente
  for all to authenticated using (perfil_id = (select auth.uid())) with check (perfil_id = (select auth.uid()));
create policy "mis planes" on public.planes_estudio
  for all to authenticated using (perfil_id = (select auth.uid())) with check (perfil_id = (select auth.uid()));
create policy "mis notificaciones" on public.notificaciones
  for all to authenticated using (perfil_id = (select auth.uid())) with check (perfil_id = (select auth.uid()));
create policy "mis dispositivos" on public.dispositivos
  for all to authenticated using (perfil_id = (select auth.uid())) with check (perfil_id = (select auth.uid()));

-- Tablas que cuelgan de otra: se valida el dueño subiendo por la llave foránea.
create policy "mis pagos" on public.pagos
  for all to authenticated using (privado.es_mi_suscripcion(suscripcion_id)) with check (privado.es_mi_suscripcion(suscripcion_id));
create policy "mis materias" on public.materias
  for all to authenticated using (privado.es_mi_periodo(periodo_id)) with check (privado.es_mi_periodo(periodo_id));
create policy "mis horarios" on public.horarios_clase
  for all to authenticated using (privado.es_mi_materia(materia_id)) with check (privado.es_mi_materia(materia_id));
create policy "mis componentes" on public.componentes_nota
  for all to authenticated using (privado.es_mi_materia(materia_id)) with check (privado.es_mi_materia(materia_id));
create policy "mis actividades" on public.actividades
  for all to authenticated using (privado.es_mi_componente(componente_id)) with check (privado.es_mi_componente(componente_id));
create policy "mis calificaciones" on public.calificaciones
  for all to authenticated using (privado.es_mi_actividad(actividad_id)) with check (privado.es_mi_actividad(actividad_id));
create policy "mis bloques" on public.bloques_estudio
  for all to authenticated using (privado.es_mi_actividad(actividad_id)) with check (privado.es_mi_actividad(actividad_id));
create policy "mis actividades del plan" on public.plan_actividades
  for all to authenticated
  using (privado.es_mi_plan(plan_id))
  with check (privado.es_mi_plan(plan_id) and privado.es_mi_actividad(actividad_id));

-- Trigger: al registrarse se crean el perfil y sus ajustes ---------------------
-- La app manda nombre y universidad_id en los metadatos del signUp. Si no manda
-- la universidad, se busca por el dominio del correo.
create or replace function privado.crear_perfil()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_universidad uuid;
begin
  v_universidad := nullif(new.raw_user_meta_data ->> 'universidad_id', '')::uuid;
  if v_universidad is null then
    select u.id into v_universidad
    from public.universidades u
    where split_part(new.email, '@', 2) = u.dominio_correo;
  end if;

  insert into public.perfiles (id, universidad_id, nombre, correo)
  values (
    new.id,
    v_universidad,
    coalesce(nullif(new.raw_user_meta_data ->> 'nombre', ''), split_part(new.email, '@', 1)),
    new.email
  );
  insert into public.ajustes_notificacion (perfil_id) values (new.id);
  return new;
end;
$$;

create trigger al_registrarse
  after insert on auth.users
  for each row execute function privado.crear_perfil();

-- Trigger: actualizado_en de las actividades -----------------------------------
create or replace function privado.marcar_actualizado()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.actualizado_en := now();
  return new;
end;
$$;

create trigger actividades_actualizado
  before update on public.actividades
  for each row execute function privado.marcar_actualizado();
