# StudyFlow

Organizador académico para estudiantes universitarios. Reúne en un solo lugar las materias, el horario de clases, las tareas, los exámenes y las notas. Además tiene un asistente que ayuda a decidir qué hacer primero y a reservar tiempo de estudio en el calendario.

Proyecto final de **Aplicaciones Móviles** · Universidad Icesi · 2026-2.

## Stack

- **App:** Flutter, con Clean Architecture y Bloc (`flutter_bloc`)
- **Backend:** Supabase (Auth, PostgreSQL con RLS y Edge Functions)
- **Diseño:** prototipo interactivo en Figma

## Enlaces

- Prototipo (play): https://www.figma.com/proto/avphm2BLhDZvOOqLqfxNbJ/StudyFlow?node-id=1-3&starting-point-node-id=1-3
- Diseño: https://www.figma.com/design/avphm2BLhDZvOOqLqfxNbJ

## Entregas

| Fecha | Entrega | Sustentación |
| --- | --- | --- |
| 27 oct | Sprint 1 | Presencial |
| 10 nov | Sprint 2 | Presencial |
| 24 nov | Sprint 3 | Virtual |
| 30 nov | Entrega final | El profesor usa la app |

## Cómo correrlo

```bash
git clone https://github.com/JmDavid1x/StudyFlow.git
cd StudyFlow
flutter pub get
flutter run
```

Al abrir la app, cualquier pantalla en construcción tiene el botón **Ver todas las pantallas**, que lleva al índice de pantallas y a la galería del design system.

## Estructura

```
lib/
  core/design_system/   tokens, tema y componentes (ver docs/design-system.md)
  core/navigation/      rutas, barra inferior y pantallas temporales
  core/demo/            datos de ejemplo del Sprint 1
  features/<feature>/   una carpeta por parte de la app (auth, subjects, tasks...)
docs/                   design system, reparto del sprint y flujo de Git
```

## Documentos

- [Design system](docs/design-system.md)
- [Sprint 1: reparto y fechas](docs/sprint-1/reparto.md)
- [Cómo trabajamos con Git](docs/flujo-git.md)
