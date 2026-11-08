-- StudyFlow · Esquema de la base de datos (18 tablas).
-- Fuente: el modelo de datos entregado al profe (docs del Sprint 1).
-- auth.users la crea y la maneja Supabase Auth; aquí solo la referenciamos.

-- Tipos (enums) ---------------------------------------------------------------
create type public.tipo_actividad as enum ('tarea', 'proyecto', 'examen');
create type public.estado_actividad as enum ('por_hacer', 'en_progreso', 'completada', 'vencida', 'no_entregada', 'pendiente', 'presentado');
create type public.canal_entrega as enum ('intu', 'correo', 'en_clase', 'whatsapp');
create type public.prioridad as enum ('baja', 'media', 'alta');
create type public.tipo_plan as enum ('diario', 'solicitado');
create type public.estado_bloque as enum ('pendiente', 'completado', 'descartado', 'cancelado');
create type public.rol_mensaje as enum ('usuario', 'asistente');
create type public.tipo_notificacion as enum ('entrega_manana', 'entrega_hoy', 'tarea_vencida', 'tarea_completada', 'bloque_por_empezar', 'bloque_pendiente', 'plan_del_dia', 'resumen_semanal');
create type public.plataforma as enum ('ios', 'android');
create type public.periodicidad as enum ('mensual', 'semestral');
create type public.estado_suscripcion as enum ('en_prueba', 'activa', 'cancelada', 'vencida');
create type public.metodo_pago as enum ('tarjeta', 'pse', 'nequi');
create type public.estado_pago as enum ('pendiente', 'aprobado', 'rechazado', 'reembolsado');

-- Cuenta ----------------------------------------------------------------------
create table public.universidades (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  dominio_correo text not null unique
);

-- El id del perfil es el mismo de auth.users. Lo crea el trigger de abajo
-- cuando alguien se registra, así la app nunca escribe en auth.users.
create table public.perfiles (
  id uuid primary key references auth.users (id) on delete cascade,
  universidad_id uuid not null references public.universidades (id) on delete restrict,
  nombre text not null,
  correo text not null unique,
  programa text,
  semestre smallint,
  configuracion_completa boolean not null default false,
  creado_en timestamptz not null default now()
);

create table public.suscripciones (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  periodicidad public.periodicidad not null,
  precio_cop integer not null check (precio_cop > 0),
  estado public.estado_suscripcion not null,
  inicia_en date not null default current_date,
  prueba_hasta date,
  vence_en date,
  renovacion_automatica boolean not null default true,
  check (estado <> 'en_prueba' or prueba_hasta is not null),
  check (prueba_hasta is null or prueba_hasta <= inicia_en + 7)
);
-- Una sola prueba gratis por perfil y una sola suscripción vigente.
create unique index un_una_prueba on public.suscripciones (perfil_id) where prueba_hasta is not null;
create unique index un_plus_vigente on public.suscripciones (perfil_id) where estado in ('en_prueba', 'activa');

-- La pasarela cobra; aquí solo queda la referencia, nunca datos de tarjeta.
create table public.pagos (
  id uuid primary key default gen_random_uuid(),
  suscripcion_id uuid not null references public.suscripciones (id) on delete cascade,
  monto_cop integer not null check (monto_cop > 0),
  metodo public.metodo_pago not null,
  estado public.estado_pago not null default 'pendiente',
  referencia_pasarela text not null unique,
  creado_en timestamptz not null default now(),
  pagado_en timestamptz,
  check ((estado = 'aprobado') = (pagado_en is not null))
);

-- Académico -------------------------------------------------------------------
create table public.periodos (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  nombre text not null,
  fecha_inicio date not null,
  fecha_fin date not null,
  meta_promedio numeric(2, 1) check (meta_promedio between 0 and 5),
  activo boolean not null default true,
  check (fecha_fin > fecha_inicio)
);
create unique index un_periodo_activo on public.periodos (perfil_id) where activo;

create table public.materias (
  id uuid primary key default gen_random_uuid(),
  periodo_id uuid not null references public.periodos (id) on delete cascade,
  nombre text not null,
  profesor text,
  creditos smallint not null check (creditos > 0),
  color text not null,
  meta_nota numeric(2, 1) check (meta_nota between 0 and 5),
  creado_en timestamptz not null default now()
);

create table public.horarios_clase (
  id uuid primary key default gen_random_uuid(),
  materia_id uuid not null references public.materias (id) on delete cascade,
  dia_semana smallint not null check (dia_semana between 1 and 7),
  hora_inicio time not null,
  hora_fin time not null,
  salon text,
  check (hora_fin > hora_inicio)
);

create table public.componentes_nota (
  id uuid primary key default gen_random_uuid(),
  materia_id uuid not null references public.materias (id) on delete cascade,
  nombre text not null,
  porcentaje numeric(5, 2) not null check (porcentaje > 0 and porcentaje <= 100)
);

-- La materia de una actividad sale de su componente (no se guarda dos veces).
create table public.actividades (
  id uuid primary key default gen_random_uuid(),
  componente_id uuid not null references public.componentes_nota (id) on delete cascade,
  titulo text not null,
  tipo public.tipo_actividad not null,
  fecha_limite timestamptz not null,
  canal_entrega public.canal_entrega,
  lugar text,
  porcentaje numeric(5, 2) not null default 0 check (porcentaje between 0 and 100),
  prioridad public.prioridad not null default 'media',
  estado public.estado_actividad not null,
  recordatorio boolean not null default true,
  notas text,
  completada_en timestamptz,
  creado_en timestamptz not null default now(),
  actualizado_en timestamptz not null default now(),
  check (
    (tipo = 'examen' and canal_entrega is null and estado in ('pendiente', 'presentado'))
    or (tipo <> 'examen' and estado in ('por_hacer', 'en_progreso', 'completada', 'vencida', 'no_entregada'))
  )
);

create table public.calificaciones (
  id uuid primary key default gen_random_uuid(),
  actividad_id uuid not null unique references public.actividades (id) on delete cascade,
  nota numeric(2, 1) not null check (nota between 0 and 5),
  registrada_en timestamptz not null default now()
);

-- Planeación y asistente ------------------------------------------------------
create table public.mensajes_asistente (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  rol public.rol_mensaje not null,
  contenido text not null,
  usado_respaldo boolean not null default false,
  creado_en timestamptz not null default now()
);

create table public.planes_estudio (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  mensaje_id uuid references public.mensajes_asistente (id) on delete set null,
  tipo public.tipo_plan not null,
  resumen text not null,
  usado_respaldo boolean not null default false,
  activo boolean not null default true,
  creado_en timestamptz not null default now()
);
create unique index un_plan_activo on public.planes_estudio (perfil_id) where activo;

-- Primero entra la actividad al plan (con su orden); después se crean bloques.
create table public.plan_actividades (
  plan_id uuid not null references public.planes_estudio (id) on delete cascade,
  actividad_id uuid not null references public.actividades (id) on delete cascade,
  orden smallint not null check (orden >= 1),
  motivo text not null,
  horas_sugeridas numeric(3, 1) check (horas_sugeridas > 0),
  primary key (plan_id, actividad_id),
  unique (plan_id, orden)
);

-- plan_id nulo = bloque creado por el usuario; con plan_id = bloque del asistente.
create table public.bloques_estudio (
  id uuid primary key default gen_random_uuid(),
  actividad_id uuid not null references public.actividades (id) on delete cascade,
  plan_id uuid,
  inicio timestamptz not null,
  fin timestamptz not null,
  estado public.estado_bloque not null default 'pendiente',
  aviso_min smallint,
  completado_en timestamptz,
  check (fin > inicio),
  foreign key (plan_id, actividad_id)
    references public.plan_actividades (plan_id, actividad_id) on delete set null (plan_id)
);

-- Avisos ----------------------------------------------------------------------
create table public.ajustes_notificacion (
  perfil_id uuid primary key references public.perfiles (id) on delete cascade,
  push_activas boolean not null default false,
  recordatorio_entregas boolean not null default true,
  dias_antes smallint not null default 1,
  aviso_mismo_dia boolean not null default true,
  horas_antes smallint not null default 3,
  aviso_bloques boolean not null default true,
  minutos_antes_bloque smallint not null default 15,
  plan_del_dia boolean not null default true,
  hora_plan time not null default '07:00',
  resumen_semanal boolean not null default true,
  dia_resumen smallint not null default 7 check (dia_resumen between 1 and 7),
  hora_resumen time not null default '18:00'
);

create table public.notificaciones (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  actividad_id uuid references public.actividades (id) on delete cascade,
  bloque_id uuid references public.bloques_estudio (id) on delete cascade,
  tipo public.tipo_notificacion not null,
  titulo text not null,
  cuerpo text not null,
  programada_para timestamptz not null,
  enviada_en timestamptz,
  leida_en timestamptz
);

create table public.dispositivos (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  token_push text not null unique,
  plataforma public.plataforma not null,
  ultimo_uso timestamptz not null default now()
);

-- Índices de las llaves foráneas (para que los joins y el RLS sean rápidos) ---
create index on public.perfiles (universidad_id);
create index on public.suscripciones (perfil_id);
create index on public.pagos (suscripcion_id);
create index on public.periodos (perfil_id);
create index on public.materias (periodo_id);
create index on public.horarios_clase (materia_id);
create index on public.componentes_nota (materia_id);
create index on public.actividades (componente_id);
create index on public.actividades (fecha_limite);
create index on public.mensajes_asistente (perfil_id, creado_en);
create index on public.planes_estudio (perfil_id);
create index on public.planes_estudio (mensaje_id);
create index on public.plan_actividades (actividad_id);
create index on public.bloques_estudio (actividad_id);
create index on public.bloques_estudio (plan_id, actividad_id);
create index on public.bloques_estudio (inicio);
create index on public.notificaciones (perfil_id, programada_para);
create index on public.notificaciones (actividad_id);
create index on public.notificaciones (bloque_id);
create index on public.dispositivos (perfil_id);
