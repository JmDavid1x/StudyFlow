# StudyFlow

Organizador académico para estudiantes universitarios. Reúne en un solo lugar las materias, el horario de clases, las tareas, los exámenes y las notas. Además tiene un asistente que ayuda a decidir qué hacer primero y a reservar tiempo de estudio en el calendario.

Proyecto final de **Aplicaciones Móviles** · Universidad Icesi · 2026-2.

## Stack

- **App:** Flutter, con Clean Architecture y Bloc (`flutter_bloc`)
- **Backend:** Supabase (Auth, PostgreSQL con RLS, Realtime y Edge Functions)
- **IA del asistente:** Gemini, llamado desde una Edge Function
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

La app ya está conectada al proyecto de Supabase (`lib/core/supabase/supabase_config.dart`), no hay que configurar nada.

Para probar con datos: regístrate con tu correo institucional, deja presionado el logo en **Iniciar sesión** (solo en modo debug) y toca **Cargar datos de ejemplo**. Eso crea en tu cuenta el semestre del prototipo: materias, tareas, un examen, bloques de estudio y notificaciones.

### Asistente con IA

El asistente le pregunta a Gemini a través de la Edge Function `asistente` (`supabase/functions/asistente`). La llave **no está en el código**: se guarda en Supabase → Edge Functions → Secrets como `GEMINI_API_KEY`. Sin llave (o si la IA falla o se acaban las 5 consultas gratis de la semana), el asistente responde con el orden de respaldo y no gasta consulta.

### APK para instalar en Android

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`. También lo arma GitHub cada vez que se fusiona algo en `main`: pestaña **Actions** → la última corrida → **Artifacts** → `studyflow-apk`. Se instala directo en el celular (permitir "instalar apps de origen desconocido").

Para revisar el código: `flutter analyze` y `flutter test`. GitHub corre los dos en cada PR (`.github/workflows/flutter.yml`).

## Estructura

```
lib/
  main.dart, app.dart   arranque: Supabase, tema, rutas y el AuthBloc de toda la app
  core/design_system/   tokens, tema y componentes (ver docs/design-system.md)
  core/navigation/      rutas y barra inferior
  core/data/            modelos compartidos: una clase por tabla de Supabase
  core/supabase/        conexión y traducción de errores de Supabase
  core/errors/          AppException y mensajeDeError (Dart puro)
  core/realtime/        cambios en vivo: RecargarEnVivo recarga una pantalla cuando cambian sus tablas
  features/<feature>/   una carpeta por parte de la app (auth, subjects, tasks...)
    domain/             repositorio abstracto, casos de uso y reglas (Dart puro)
    data/               implementación del repositorio con Supabase
    ui/                 bloc/, screens/, widgets/
supabase/migrations/    el esquema SQL: tablas, seguridad (RLS), triggers, funciones y Realtime
supabase/functions/     Edge Functions (asistente con IA)
test/                   tests de modelos, casos de uso, Blocs y flujos de pantalla
docs/                   design system, reparto de cada sprint, base de datos y flujo de Git
```

## Documentos

- [Design system](docs/design-system.md)
- [Sprint 1: reparto y fechas](docs/sprint-1/reparto.md)
- [Sprint 2: reglas y reparto](docs/sprint-2/reparto.md)
- [Sprint 3: reparto](docs/sprint-3/reparto.md)
- [Base de datos (Supabase)](docs/sprint-2/base-de-datos.md)
- [Cómo trabajamos con Git](docs/flujo-git.md)

## Equipo

Jose David Mayor López, Miguel, Alejandro Pérez, Camilo y Santiago.

---

Este trabajo fue apoyado con herramientas de inteligencia artificial.
