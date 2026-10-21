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

## Estructura del repositorio

```
docs/        modelo de datos, alcance por sprint y decisiones
supabase/    migraciones de la base de datos y pruebas SQL
tools/       prototipos y pruebas que no son parte de la app
```

La app de Flutter se agrega en la raíz del repositorio en el Sprint 1.
