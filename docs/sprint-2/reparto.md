# Sprint 2 · Reparto y reglas (entrega: martes 10 de noviembre)

Objetivo: que la app deje de usar `DemoData` y funcione con datos reales de Supabase, manejando el estado con BLoC y separando el código en capas (Clean Architecture).

## Fechas

| Día | Qué |
| --- | --- |
| Sáb 7 | Cada uno: capa `domain` + `data` (repositorio) → **commit 1** |
| Dom 8 | Cada uno: Bloc/Cubit y pantallas conectadas → **commit 2** |
| Lun 9 | Cada uno: lo que falte + tests → **commit 3** y **PR a `main` antes de las 8 p. m.** |
| Mar 10 | Revisión y merge en orden, ensayo de la demo |

Mínimo **un commit por día**, cada uno desde su cuenta. Nada de hacer todo en un día: el profe revisa los commits de cada uno.

## Cómo empezar

```bash
git checkout main
git pull
git checkout -b feature/s2-<tu-feature>   # p. ej. feature/s2-materias
flutter pub get
```

## Estructura de cada feature

```
lib/features/<feature>/
├── domain/
│   ├── <feature>_repository.dart     ← clase abstracta: QUÉ datos se piden
│   └── usecases/                     ← una clase por acción con reglas (CompletarActividad)
├── data/
│   └── <feature>_repository_impl.dart ← CÓMO se piden a Supabase
└── ui/
    ├── bloc/                         ← <x>_bloc.dart, <x>_event.dart, <x>_state.dart (o un Cubit)
    ├── screens/                      ← las pantallas del Sprint 1, ahora con BlocBuilder
    └── widgets/
```

Reglas en `domain`: Dart puro (sin Flutter, sin Supabase). Los cálculos (nota, promedio, orden sugerido, filtros por fecha) van ahí y se prueban con tests.

## Reglas (para no pisarnos)

1. **Solo tocas tu carpeta** de `lib/features/` y tus tests en `test/features/<tu-feature>/`.
2. **No edites `lib/core/`** (modelos, design system, navegación, Supabase). Si te falta algo ahí (un campo, un select, una ruta), pídeselo a Jose en el grupo.
3. **Modelos compartidos:** `import 'package:studyflow/core/data/data.dart';` → `Actividad`, `Materia`, `BloqueEstudio`, `Perfil`, `AjustesNotificacion`, etc. Cada uno tiene `fromMap` y `toInsert`, y algunos un `select` listo con sus relaciones.
4. **Cliente de Supabase:** `import 'package:studyflow/core/supabase/supabase_x.dart';` → `supabase` y `supabase.usuarioId`. El repositorio lo recibe por el constructor.
5. **Errores:** el repositorio hace `catch (e) { throw AppException(mensajeDeError(e)); }` (`core/errors/app_exception.dart`) y el Bloc muestra `e.mensaje`.
6. **No filtres por usuario:** la base ya devuelve solo las filas del usuario con sesión (RLS). Solo mandas `perfil_id` al **insertar** en tablas que lo tienen.
7. **Los Blocs se crean en tu carpeta:** en tu `*_routes.dart` (`BlocProvider(create: ..., child: TuPantalla())`) o, si es una pestaña, envolviendo tu pantalla en un widget de tu carpeta.
8. **Refrescar:** al volver de otra pantalla (`await Navigator.pushNamed(...)`) vuelve a cargar tu Bloc, porque otro integrante pudo cambiar los datos.
9. **Deja de usar `DemoData`** en tus pantallas.
10. `flutter analyze` sin errores y `flutter test` en verde antes de cada commit.

## Ejemplo mínimo (patrón a copiar)

```dart
// domain/tasks_repository.dart
abstract class TasksRepository {
  Future<List<Actividad>> actividadesDelPeriodo();
  Future<void> cambiarEstado(String id, EstadoActividad estado);
}

// data/tasks_repository_impl.dart
class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl(this._db);
  final SupabaseClient _db;

  @override
  Future<List<Actividad>> actividadesDelPeriodo() async {
    try {
      final filas = await _db
          .from('actividades')
          .select(Actividad.selectPeriodoActivo)
          .eq('componentes_nota.materias.periodos.activo', true)
          .order('fecha_limite');
      return filas.map(Actividad.fromMap).toList();
    } catch (e) {
      throw AppException(mensajeDeError(e));
    }
  }
  // ...
}
```

## Quién hace qué

### Jose · core + acceso (`auth/`, `core/`)
Modelos compartidos y guía (sáb), AuthRepository + AuthBloc con registro, login, recuperar contraseña y cerrar sesión reales (dom), Splash que revisa la sesión y tests (lun). Expone `AuthBloc` arriba de toda la app para que Perfil cierre sesión.

### Miguel · materias (`subjects/`)
Tablas: `periodos`, `materias`, `horarios_clase`, `componentes_nota`, `calificaciones`, y `perfiles.configuracion_completa` / `ajustes_notificacion.push_activas` al terminar la configuración.
- Configuración inicial (08–10): crear el periodo activo, las materias con horarios y componentes (deben sumar 100 %), activar recordatorios y marcar `configuracion_completa = true`.
- Pestaña Materias y detalle: nota acumulada, % evaluado, nota que falta para la meta y promedio del semestre (ponderado por créditos). Fórmulas en `docs/` del modelo de datos.
- Registrar nota (23/S3): insertar en `calificaciones` y recalcular.

### Alejandro · inicio + tareas (`home/`, `tasks/`)
Tablas: `actividades` (leer, cambiar estado, eliminar), `notificaciones`, `bloques_estudio` (solo leer para Inicio).
- Tareas: lista real con filtros (vencidas, hoy, esta semana, completadas).
- Detalle de tarea/examen: completar (`estado = completada`, `completada_en = ahora`, y cancelar sus bloques pendientes), no entregada, eliminar; examen → presentado.
- Inicio: saludo con el nombre del perfil, tarjetas (entregas de la semana, próximo examen, horas de estudio planeadas), progreso semanal, prioridades y próximas.
- Notificaciones: lista real, marcar leída, borrar.

### Camilo · formulario, calendario y bloques (`task_form/`, `calendar/`, `study_blocks/`)
Tablas: `actividades` (crear y editar), `materias` + `componentes_nota` (solo leer para los selectores), `horarios_clase` (leer), `bloques_estudio` (crear, completar, reprogramar, descartar).
- Nueva/Editar tarea: guarda en Supabase; examen sin canal de entrega y con estado `pendiente`; tarea con estado `por_hacer`.
- Calendario: la semana con clases (`horarios_clase` por `dia_semana`), entregas y bloques del día.
- Bloques: crear sin cruzarse con clases ni con otros bloques; completar (si es el primero, la actividad pasa a `en_progreso`), reprogramar, descartar.

### Santiago · asistente, perfil y Plus (`assistant/`, `profile/`, `subscription/`)
Tablas: `perfiles` (leer/editar), `ajustes_notificacion`, `mensajes_asistente`, `planes_estudio`, `plan_actividades`, `bloques_estudio` (crear desde el plan), `suscripciones`, `pagos`.
- Perfil: datos reales, plan actual (gratis o Plus) y consultas usadas; cerrar sesión con el `AuthBloc` de Jose.
- Ajustes de notificaciones: leer y guardar.
- Asistente: guardar la conversación; "orden de respaldo" en Dart puro (vence primero → más porcentaje → prioridad alta) que no gasta consulta; límite de 5 consultas por semana en el plan gratis; "Agregar al plan" crea el plan, sus actividades en orden y los bloques.
- Plus y pago: crear la suscripción `en_prueba` (7 días) y un pago simulado con referencia generada; solo una prueba por perfil (la base lo impide: mostrar el mensaje).
