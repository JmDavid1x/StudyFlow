# Prompt para Claude Code · Persona 4 (Persona 4)

> Abre Claude Code en la carpeta del repo, en tu rama `feature/calendario-bloques`, y pega todo lo que está debajo de la línea. Adjunta las capturas de tus pantallas del prototipo de Figma (play: https://www.figma.com/proto/avphm2BLhDZvOOqLqfxNbJ/StudyFlow?node-id=1-3&starting-point-node-id=1-3).

---

Vas a construir mis pantallas del **Sprint 1 de StudyFlow** (solo interfaz, con datos de ejemplo, sin Supabase).

Antes de escribir código, lee completos: `CLAUDE.md`, `docs/design-system.md`, `docs/sprint-1/reparto.md`, `lib/core/design_system/design_system.dart` y los componentes que vayas a usar, `lib/core/navigation/app_routes.dart` y `lib/core/demo/demo_data.dart`. Sigue todas las reglas de `CLAUDE.md`.

## Mis pantallas

Las capturas adjuntas son la referencia visual. Respeta el orden, los textos y la jerarquía de cada una.

- 14 Nueva tarea: título, tipo (SfOptionCards: tarea, proyecto, examen), materia (SfOptionCards con el color de cada materia), fecha y hora (SfPickerField), canal de entrega, prioridad, porcentaje y recordatorio. Guardar lleva a 15.
- 15 Tarea guardada: confirmación con resumen y botones para volver al Inicio o agregar otra.
- 19 Editar tarea: el mismo formulario de 14 con datos cargados; reutiliza los widgets de 14 (ponlos en task_form/ui/widgets/).
- 20 Calendario (pestaña, archivo features/calendar/ui/screens/calendar_screen.dart): mes con flechas, franja de días de la semana (al tocar un día se ve solo ese día), y la agenda del día con clases, bloques y entregas. SfFab abre S7 Agregar (hoja inferior: agregar tarea o bloque).
- 27 Bloque de estudio: detalle del bloque, completar (S5 Bloque completado) y reprogramar; S10 Bloque pendiente cuando ya pasó la hora.
- 28 Nuevo bloque: actividad (SfOptionCards), fecha, hora de inicio y duración con selectores.

## Dónde trabajo

- Solo edito: `lib/features/task_form/, features/calendar/ y features/study_blocks/` y su archivo de rutas (task_form_routes.dart y study_blocks_routes.dart).
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
