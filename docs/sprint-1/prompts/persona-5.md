# Prompt para Claude Code · Persona 5 (Persona 5)

> Abre Claude Code en la carpeta del repo, en tu rama `feature/asistente-perfil-plus`, y pega todo lo que está debajo de la línea. Adjunta las capturas de tus pantallas del prototipo de Figma (play: https://www.figma.com/proto/avphm2BLhDZvOOqLqfxNbJ/StudyFlow?node-id=1-3&starting-point-node-id=1-3).

---

Vas a construir mis pantallas del **Sprint 1 de StudyFlow** (solo interfaz, con datos de ejemplo, sin Supabase).

Antes de escribir código, lee completos: `CLAUDE.md`, `docs/design-system.md`, `docs/sprint-1/reparto.md`, `lib/core/design_system/design_system.dart` y los componentes que vayas a usar, `lib/core/navigation/app_routes.dart` y `lib/core/demo/demo_data.dart`. Sigue todas las reglas de `CLAUDE.md`.

## Mis pantallas

Las capturas adjuntas son la referencia visual. Respeta el orden, los textos y la jerarquía de cada una.

- 24 Asistente: chat con burbujas, contador "3 de 5 gratis", tarjeta "Este es tu orden sugerido" con actividades numeradas, botón "Agregar plan al calendario" que abre S4 Plan agregado (primero las actividades en orden y debajo de cada una sus bloques), sugerencias rápidas en chips y campo para escribir.
- 31 Asistente sin conexión: mismo chat con un aviso de que la IA no respondió, el orden de respaldo, "Reintentar" y la nota "esta respuesta no gasta tus consultas gratis". Puede ser un estado de la pantalla 24.
- 25 Perfil (pestaña, archivo features/profile/ui/screens/profile_screen.dart): SfAvatar con la inicial, datos del estudiante, plan actual, accesos a ajustes de notificaciones y a Plus, y cerrar sesión.
- 26 Ajustes de notificaciones: interruptores y selectores de cuándo avisar (entregas, bloques, plan del día, resumen semanal).
- 30 StudyFlow Plus: tabla Gratis vs Plus, consultas gratis de la semana (SfProgressBar), SfSegmented Mensual / Semestre y "Probar 7 días gratis" que lleva a 32.
- 32 Pago: resumen (hoy pagas COP 0, fin de la prueba, primer cobro), método de pago con SfOptionCards de una columna (tarjeta, PSE, Nequi) y "Iniciar prueba gratis", que abre S11 Prueba activada (SfResultSheet) y lleva al asistente.

## Dónde trabajo

- Solo edito: `lib/features/assistant/, features/profile/ y features/subscription/` y su archivo de rutas (assistant_routes.dart, profile_routes.dart y subscription_routes.dart).
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
