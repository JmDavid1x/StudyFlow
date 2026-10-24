# Prompt para Claude Code · Persona 3 (Persona 3)

> Abre Claude Code en la carpeta del repo, en tu rama `feature/inicio-tareas`, y pega todo lo que está debajo de la línea. Adjunta las capturas de tus pantallas del prototipo de Figma (play: https://www.figma.com/proto/avphm2BLhDZvOOqLqfxNbJ/StudyFlow?node-id=1-3&starting-point-node-id=1-3).

---

Vas a construir mis pantallas del **Sprint 1 de StudyFlow** (solo interfaz, con datos de ejemplo, sin Supabase).

Antes de escribir código, lee completos: `CLAUDE.md`, `docs/design-system.md`, `docs/sprint-1/reparto.md`, `lib/core/design_system/design_system.dart` y los componentes que vayas a usar, `lib/core/navigation/app_routes.dart` y `lib/core/demo/demo_data.dart`. Sigue todas las reglas de `CLAUDE.md`.

## Mis pantallas

Las capturas adjuntas son la referencia visual. Respeta el orden, los textos y la jerarquía de cada una.

- 11, 12 y 16 Inicio (pestaña, archivo features/home/ui/screens/home_screen.dart): saludo con fecha, botones de asistente y notificaciones, tarjetas de datos (SfStatCard), progreso semanal, "Tu plan de hoy" (SfCard destacada), "Prioridades de hoy" y "Próximas" con SfTaskTile, y el SfFab que lleva a Nueva tarea. 11 es el estado vacío (sin materias o sin tareas) y 16 el estado después de guardar una tarea.
- 13 Notificaciones: lista de avisos agrupados por día, con estado vacío.
- 17 Tareas (pestaña, archivo features/tasks/ui/screens/tasks_screen.dart): SfChipBar con Todas, Hoy, Esta semana, Completadas; secciones Hoy, Esta semana y Completadas con SfTaskTile; SfFab.
- 18 Detalle de tarea: datos de la tarea, bloques de estudio y acciones. Abre S1 Tarea completada, S2 Eliminar tarea (confirmación con SfButton danger) y S8 Tarea vencida como hojas inferiores.
- 29 Detalle de examen: fecha, lugar, porcentaje y estado (pendiente o presentado; un examen no tiene "en progreso").

## Dónde trabajo

- Solo edito: `lib/features/home/ y features/tasks/` y su archivo de rutas (tasks_routes.dart).
- No edito pantallas ni rutas de otras personas. Si necesito algo del design system que no existe, créalo en `lib/core/design_system/components/`, regístralo en `design_system.dart` y en la tabla de `docs/design-system.md`, y avísame para contárselo al grupo.
- Los botones que llevan a pantallas de otros navegan igual con `AppRoutes`: hoy llegan a su pantalla temporal y mañana a la real.

## Cómo quiero que trabajes

1. Muéstrame primero un plan corto: qué archivos vas a crear y qué componentes usará cada pantalla.
2. Construye **una pantalla a la vez**. Al terminar cada una:
   - reemplaza su `PlaceholderScreen` en mi archivo de rutas;
   - corre `flutter analyze` y corrige todo;
   - dime qué probar en el emulador;
   - **no hagas commit**: yo reviso el código, lo entiendo y hago el commit con mi cuenta.
3. Usa solo datos de `DemoData` o textos del prototipo. No inventes cifras nuevas.
4. Cada lista tiene estado vacío. Cada hoja inferior se abre con `showSfBottomSheet`.
5. Al final, dame un resumen de 5 líneas de cómo funciona cada pantalla, para poder explicarla en la sustentación.
