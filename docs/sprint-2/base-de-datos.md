# Base de datos (Supabase)

Proyecto: `studyflow` · https://vgrnqvsrdojnpnxgqybe.supabase.co

La app ya se conecta sola (`lib/core/supabase/supabase_config.dart`). No hay que configurar nada para correrla.

## Migraciones (`supabase/migrations/`)

| Archivo | Qué hace |
| --- | --- |
| `…_esquema.sql` | Los 13 enums y las 18 tablas del modelo de datos, con sus checks e índices |
| `…_seguridad_y_triggers.sql` | RLS en todas las tablas, el trigger que crea el perfil al registrarse y el de `actualizado_en` |
| `…_semilla_universidades.sql` | Las 5 universidades de Cali del registro |
| `…_datos_de_ejemplo.sql` | RPC `cargar_datos_ejemplo()`: el semestre del prototipo para el usuario con sesión (menú de desarrollo) |
| `…_seguridad_reglas.sql` | Ajustes tras la auditoría: Plus solo por RPC, perfil con columnas editables, registro que no se rompe, FKs ajenas bloqueadas, componentes ≤ 100 %, `completada_en` automático y checks de rango |

Ya están aplicadas en el proyecto. Si alguien necesita un cambio en una tabla, se le pide a Jose y se agrega como una migración nueva (nunca se edita una vieja).

## Reglas que hay que saber

- **Cada usuario solo ve sus filas (RLS).** No hace falta filtrar por `perfil_id` en las consultas: la base ya lo hace con `auth.uid()`. Las tablas sin `perfil_id` (materias, actividades, bloques…) se validan subiendo por sus llaves foráneas hasta el perfil.
- **Al insertar** en una tabla que sí tiene `perfil_id` (periodos, mensajes, planes, notificaciones, suscripciones), hay que mandarlo: `Supabase.instance.client.auth.currentUser!.id`.
- **El perfil y los ajustes de notificación los crea la base** cuando alguien se registra (trigger `al_registrarse`). La app nunca inserta en `perfiles` ni en `ajustes_notificacion`, solo los lee y los actualiza.
- **La materia de una actividad** sale de su componente: `actividades → componentes_nota → materias`. En Supabase se pide así:
  ```dart
  supabase.from('actividades').select('*, componentes_nota(nombre, materias(id, nombre, color))');
  ```
- **Estados por tipo:** tarea y proyecto usan `por_hacer · en_progreso · completada · vencida · no_entregada`; examen usa `pendiente · presentado` y no lleva `canal_entrega`. La base rechaza otra combinación.
- **Un solo periodo activo, un solo plan activo, una sola prueba gratis por perfil** (índices únicos).
- **Plus y pagos son de solo lectura** para la app. La prueba gratis se pide con `supabase.rpc('iniciar_prueba', params: {'p_periodicidad': 'mensual', 'p_metodo': 'nequi'})`: crea la suscripción `en_prueba` (7 días) y un pago `pendiente`. Si ya la usó, falla con 23505.
- **Del perfil solo se actualizan** `nombre`, `programa`, `semestre` y `configuracion_completa` (`Perfil.toUpdate()`). El correo lo copia la base desde Supabase Auth.
- **Los componentes de una materia no pueden sumar más de 100 %** (la base lo revisa al final de la transacción).
- **`completada_en` lo maneja la base:** se llena al pasar a `completada` o `presentado` y se borra en cualquier otro estado.
- **"Vencida" la calcula la app** (`Actividad.estaVencida()`); la base no cambia estados por fecha.
- **Errores:** `mensajeDeError(e)` (en `core/errors/app_exception.dart`, Dart puro) usa el traductor de Supabase que registra `main.dart`, así los mensajes salen en español sin que el domain dependa de Supabase.
