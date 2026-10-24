# Sprint 1 · Interfaz completa (entrega: lunes 27 de octubre)

**Objetivo:** todas las pantallas del prototipo construidas en Flutter, navegables y con datos de ejemplo. Sin Supabase ni lógica real: eso es el Sprint 2.

Prototipo (play): https://www.figma.com/proto/avphm2BLhDZvOOqLqfxNbJ/StudyFlow?node-id=1-3&starting-point-node-id=1-3
Diseño: https://www.figma.com/design/avphm2BLhDZvOOqLqfxNbJ

## Lo que ya está en `main`

- Proyecto Flutter con la estructura por features (Clean Architecture: en este sprint solo la capa `ui`).
- **Design system** en `lib/core/design_system/` con tokens, tema, 20 componentes y una galería. Guía: [docs/design-system.md](../design-system.md).
- Navegación: todas las rutas creadas, la barra inferior con las 5 pestañas y una pantalla temporal en cada ruta que dice de quién es.
- Menú de desarrollo (`/dev`) para abrir cualquier pantalla directo.
- Datos de ejemplo en `lib/core/demo/demo_data.dart`.

## Reparto

Cada persona tiene su propia carpeta y su propio archivo de rutas, así nadie pisa el código de otro.

| Persona | Rama | Pantallas (número en Figma) | Carpetas |
| --- | --- | --- | --- |
| **1 · Jose David** | `feature/acceso` | 01 Splash, 02-03 Onboarding, 04 Registro, 05 Iniciar sesión, 06 Recuperar contraseña, 07 Correo enviado. Además: base del proyecto, design system y navegación | `features/auth/`, `core/` |
| **2 · Miguel** | `feature/materias` | 08 Tus materias, 09 Nueva materia + S9 Horario de clase, 10 Activar recordatorios, 21 Materias (pestaña), 22 Detalle de materia, 23 Registrar nota + S3 Nota registrada | `features/subjects/` |
| **3 · Perez** | `feature/inicio-tareas` | 11, 12 y 16 Inicio (vacío, normal y actualizado), 13 Notificaciones, 17 Tareas (pestaña), 18 Detalle de tarea + S1 Completada + S2 Eliminar + S8 Vencida, 29 Detalle de examen | `features/home/`, `features/tasks/` |
| **4 · Camilo** | `feature/calendario-bloques` | 14 Nueva tarea, 15 Tarea guardada, 19 Editar tarea, 20 Calendario (pestaña) + S7 Agregar, 27 Bloque de estudio + S5 Completado + S10 Pendiente, 28 Nuevo bloque | `features/task_form/`, `features/calendar/`, `features/study_blocks/` |
| **5 · Santiago** | `feature/asistente-perfil-plus` | 24 Asistente + S4 Plan agregado + 31 Sin conexión, 25 Perfil (pestaña), 26 Ajustes de notificaciones, 30 StudyFlow Plus, 32 Pago + S11 Prueba activada | `features/assistant/`, `features/profile/`, `features/subscription/` |

## Cómo construir una pantalla

1. Mírala en el prototipo de Figma (toma captura).
2. Crea el archivo en `lib/features/<tu-feature>/ui/screens/<nombre>_screen.dart`. Las partes que se repiten van en `ui/widgets/`.
3. Usa **solo** componentes y tokens del design system (ver la guía).
4. En el archivo `*_routes.dart` de tu feature, cambia el `PlaceholderScreen` por tu pantalla.
5. Conecta la navegación: los botones de tu pantalla llevan a las rutas de `AppRoutes` (aunque la pantalla de destino sea de otra persona).
6. Corre `flutter analyze` (sin errores) y prueba en el emulador.
7. Commit y push a tu rama. Un commit por pantalla terminada.

## Fechas

| Cuándo | Qué |
| --- | --- |
| Sábado 24 | Cada uno clona, crea su rama y hace su primer commit (una pantalla) |
| Domingo 25, 8:00 p. m. | Todas las pantallas en Pull Request |
| Domingo 25, noche | Revisión cruzada y merge a `main` |
| Lunes 27, antes de clase | Repaso juntos: cada uno explica sus pantallas a los demás |

## Para la sustentación

El profe pregunta a cualquiera por cualquier parte. Todos deben saber explicar:

- Cómo está organizado el proyecto (features, `core/`, design system).
- Cómo funciona la navegación: `AppRoutes`, los archivos `*_routes.dart` y `MainShell` con la barra inferior.
- Qué es un token y por qué no se escriben colores a mano.
- Cómo se usa un selector (`SfOptionCards`, `SfPickerField`) y una hoja inferior (`showSfBottomSheet`).
- Qué cambia en el Sprint 2: los datos de ejemplo se reemplazan por Supabase con Bloc.
