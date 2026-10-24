# StudyFlow · instrucciones para asistentes de código

App Flutter del curso Aplicaciones Móviles (Universidad Icesi). Organizador académico para estudiantes: materias, horario, tareas, exámenes, notas, bloques de estudio y un asistente.

## Sprint actual: Sprint 1, solo interfaz

- Construir pantallas con datos de ejemplo (`lib/core/demo/demo_data.dart`). **No** conectar Supabase ni escribir lógica de negocio todavía.
- Cada pantalla corresponde a un número del prototipo en Figma: https://www.figma.com/proto/avphm2BLhDZvOOqLqfxNbJ/StudyFlow?node-id=1-3&starting-point-node-id=1-3
- El reparto de pantallas está en `docs/sprint-1/reparto.md`. Trabaja solo en las carpetas de la persona que te está usando.

## Estructura

```
lib/
  app.dart, main.dart
  core/
    design_system/   tokens, tema, componentes Sf* y galería
    navigation/      AppRoutes, AppRouter, MainShell (barra inferior), pantallas temporales
    demo/            datos de ejemplo del Sprint 1
    dev/             menú de desarrollo (/dev)
  features/<feature>/
    <feature>_routes.dart   rutas de la feature (solo las edita su dueño)
    ui/screens/             una pantalla por archivo
    ui/widgets/             piezas que se repiten dentro de la feature
    (Sprint 2: domain/ y data/ con Clean Architecture y Bloc)
```

## Reglas obligatorias

1. Importa el design system con `import 'package:studyflow/core/design_system/design_system.dart';` y lee `docs/design-system.md` antes de escribir una pantalla.
2. **Nunca** escribas colores, tamaños de letra, espacios ni radios a mano. Usa `SfColors`, `SfTypography`, `SfSpacing` y `SfRadius`.
3. Reutiliza los componentes `Sf*`. Si hace falta uno nuevo que sirva a otras pantallas, créalo en `core/design_system/components/` y agrégalo a `design_system.dart` y a la tabla de `docs/design-system.md`.
4. Nada de desplegables ni teclado para datos que se eligen: fechas y horas con `SfPickerField` + `sfPickDate` / `sfPickTime`; opciones con `SfOptionCards`, `SfSegmented` o `SfChipBar`.
5. Las hojas inferiores (S1 a S11) se abren con `showSfBottomSheet`; las de resultado usan `SfResultSheet`.
6. Navega solo con las constantes de `AppRoutes` (`Navigator.pushNamed(context, AppRoutes.newTask)`). Las pestañas se abren con `Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false, arguments: AppTabs.home)`.
7. Cuando una pantalla esté lista, reemplaza su `PlaceholderScreen` en el archivo `*_routes.dart` de su feature. No edites `core/navigation/app_router.dart`.
8. Cada pantalla: `Scaffold` + `SafeArea`, margen lateral `SfSpacing.screen`, contenido con scroll si puede no caber, y estado vacío cuando muestra una lista.
9. Textos de la interfaz en español, sin raya larga (—). Nombres de clases, archivos y variables en inglés.
10. Archivos en `snake_case`, clases en `PascalCase`, `const` siempre que se pueda, imports con `package:studyflow/...`.
11. Antes de terminar: `flutter analyze` sin errores ni advertencias.
12. Commits pequeños, uno por pantalla o componente, con mensajes `feat: ...`, `fix: ...`, `refactor: ...`. Nunca a `main` directo.
