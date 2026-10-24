# Prompt para Claude Code · Persona 2 (Persona 2)

> Abre Claude Code en la carpeta del repo, en tu rama `feature/materias`, y pega todo lo que está debajo de la línea. Adjunta las capturas de tus pantallas del prototipo de Figma (play: https://www.figma.com/proto/avphm2BLhDZvOOqLqfxNbJ/StudyFlow?node-id=1-3&starting-point-node-id=1-3).

---

Vas a construir mis pantallas del **Sprint 1 de StudyFlow** (solo interfaz, con datos de ejemplo, sin Supabase).

Antes de escribir código, lee completos: `CLAUDE.md`, `docs/design-system.md`, `docs/sprint-1/reparto.md`, `lib/core/design_system/design_system.dart` y los componentes que vayas a usar, `lib/core/navigation/app_routes.dart` y `lib/core/demo/demo_data.dart`. Sigue todas las reglas de `CLAUDE.md`.

## Mis pantallas

Las capturas adjuntas son la referencia visual. Respeta el orden, los textos y la jerarquía de cada una.

- 08 Tus materias (configuración inicial): lista de materias agregadas y botón para agregar otra; "Continuar" lleva a 10.
- 09 Nueva materia: nombre, profesor, créditos (selector), color (selector de colores con SfColors.subjectColors), meta de nota y componentes de la nota. Desde aquí se abre S9 Horario de clase (hoja inferior con día y horas con SfPickerField).
- 10 Activar recordatorios: explica los avisos y deja activarlos; termina en el Inicio.
- 21 Materias (pestaña, archivo ui/screens/subjects_screen.dart): tarjetas de cada materia con su color, nota actual y meta.
- 22 Detalle de materia: anillo de nota actual vs. meta (SfProgressRing), "Cómo se calcula tu nota" por componente y lista de actividades.
- 23 Registrar nota: actividad (SfOptionCards) y nota (selector, no teclado). Al guardar abre S3 Nota registrada (SfResultSheet).

## Dónde trabajo

- Solo edito: `lib/features/subjects/` y su archivo de rutas (subjects_routes.dart).
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
