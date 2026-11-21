# Sprint 3 · Reparto y reglas (entrega: martes 24 de noviembre, virtual)

Objetivo: que la app quede lista para que el profe la use el 30 de noviembre. Ya está conectada a Supabase (Sprint 2); ahora le sumamos lo que la hace "real": IA en el asistente, cambios en vivo, recordatorios y pulir cada parte.

## Fechas

| Día | Qué |
| --- | --- |
| Sáb 21 | Cada uno: primera parte de su tarea → **commit 1** |
| Dom 22 | Lo principal funcionando → **commit 2** |
| Lun 23 | Tests + arreglos → **commit 3** y **PR a `main` antes de las 8 p. m.** |
| Mar 24 | Merge en orden y sustentación virtual |

Mínimo **un commit por día**, cada uno desde su cuenta.

## Ya hecho (Jose)

- **Asistente con IA:** Edge Function `asistente` (Gemini) con el límite de consultas en el servidor. La app la llama en `AssistantRepositoryImpl.responderConIA`; si falla, usa el orden de respaldo.
- **Cambios en vivo:** `lib/core/realtime/`. Envuelve tu pantalla con `RecargarEnVivo(tablas: {...}, alCambiar: ..., child: ...)` y se recarga sola cuando cambian esas tablas (ver `docs/sprint-2/base-de-datos.md`). Ya lo usan Inicio y Tareas.
- **CI** fijado a Flutter 3.44.8. Usa esa versión (`flutter --version`).

## Cómo empezar

```bash
git checkout main
git pull
git checkout -b feature/s3-<tu-feature>
flutter pub get
```

Las reglas del Sprint 2 siguen igual (`docs/sprint-2/reparto.md`): solo tu carpeta, `domain` en Dart puro, errores con `mensajeDeError`, `flutter analyze` y `flutter test` en verde antes de cada commit.

## Reparto

| Quién | Rama | Tarea |
| --- | --- | --- |
| Santiago | `feature/s3-asistente-ui` | Asistente con la IA real: estado "pensando", respuesta con formato, Plus pulido y tests |
| Miguel | `feature/s3-recordatorios` | Recordatorios locales de entregas y bloques según `ajustes_notificacion`; Materias en vivo |
| Alejandro | `feature/s3-inicio-tareas` | Arreglos de la revisión (próximo examen, completar), estados vacíos y tests |
| Camilo | `feature/s3-calendario-bloques` | Arreglos de la revisión (porcentaje, editar), calendario en vivo y test de flujo |
| Jose | `feature/s3-asistente-ia`, `feature/s3-realtime` | IA, Realtime, revisión de PRs y APK final |
