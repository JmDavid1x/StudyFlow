# Design system de StudyFlow

Todo lo visual de la app sale de `lib/core/design_system/`. Así las pantallas de los cinco se ven como una sola app y cualquiera puede explicar cualquier pantalla en la sustentación.

```dart
import 'package:studyflow/core/design_system/design_system.dart';
```

Para verlo todo junto, abre la app y entra a **Pantallas del Sprint 1 → Ver el design system** (ruta `/dev/design-system`).

## Reglas

1. **Nada de colores, tamaños ni fuentes a mano.** Nada de `Color(0xFF...)`, `TextStyle(fontSize: 13)` ni `EdgeInsets.all(13)` en las pantallas. Se usan `SfColors`, `SfTypography`, `SfSpacing` y `SfRadius`. Si falta algo, se agrega al design system y se anota aquí.
2. **Si un componente ya existe, se usa.** Si necesitas uno nuevo que otra persona también puede usar, va en `components/` con el prefijo `Sf` y se anota en la tabla de abajo.
3. **Nada de desplegables.** Fechas, horas, materias, tipos y porcentajes se eligen con selectores (`SfPickerField`, `SfOptionCards`, `SfSegmented`), nunca escribiendo con el teclado.
4. **Una sola acción principal por pantalla.** Es el `SfButton` violeta. Las demás acciones son `secondary` o `ghost`.
5. **Toda lista tiene estado vacío.** Si hay datos que cargar, también tiene estado de carga y de error (`SfEmptyState`, `SfLoadingState`, `SfErrorState`). El estado vacío dice qué hacer, no solo "No hay datos".
6. **Toques de al menos 44 × 44.** Los componentes ya lo cumplen; no los achiques.
7. **Textos en español y sin raya larga (—).** Se usan coma, punto o dos puntos.

## Tokens

### Colores (`SfColors`)

| Token | Hex | Para qué |
| --- | --- | --- |
| `background` | `#0A0812` | Fondo de todas las pantallas |
| `surface` | `#16122A` | Tarjetas, campos, botones secundarios |
| `surfaceRaised` | `#17122C` | Hojas inferiores y diálogos |
| `primarySoft` | `#1E1540` | Fondo de lo seleccionado o destacado |
| `border` | `#2A2445` | Bordes y divisores |
| `borderStrong` | `#3A2F66` | Borde de controles sin seleccionar |
| `primary` | `#7C3AED` | Acción principal (botón, FAB, selección) |
| `primaryLight` | `#A78BFA` | Texto o ícono activo, enlaces |
| `textPrimary` | `#FFFFFF` | Texto principal |
| `textSecondary` | `#A9A3C2` | Texto de apoyo |
| `textDisabled` | `#6B6685` | Placeholders y deshabilitado |
| `success` | `#22C55E` | Completada, guardado |
| `warning` | `#F59E0B` | Prioridad media, por vencer |
| `danger` | `#F87171` | Prioridad alta, vencida, error |
| `info` | `#2DD4BF` | Bloques de estudio y entregas |
| `subjectColors` | lista | Colores que el usuario le pone a cada materia |

**Por qué esta paleta.** La app es oscura porque se usa mucho de noche, al planear el día siguiente. Hay un solo color de marca (el violeta) y se reserva para la acción principal. Los colores de estado significan siempre lo mismo, para que el usuario aprenda a leerlos.

### Tipografía (`SfTypography`)

| Estilo | Fuente | Tamaño | Uso |
| --- | --- | --- | --- |
| `display` | Raleway Bold | 30 | Título de pestaña: "Calendario" |
| `h1` | Raleway Bold | 26 | Título de pantalla: "Crea tu cuenta" |
| `h2` | Raleway Bold | 20 | Encabezado de sección |
| `title` | DM Sans Bold | 17 | Barra superior, título de tarjeta |
| `bodyStrong` | DM Sans SemiBold | 14.5 | Nombre de tarea, opción |
| `body` | DM Sans | 14.5 | Texto normal |
| `button` | DM Sans SemiBold | 16 | Botones |
| `label` | DM Sans SemiBold | 13 | Etiqueta de un campo |
| `caption` | DM Sans | 12.5 | Fechas, materia, ayudas |
| `number` | DM Mono | 14 | Notas, porcentajes, horas |

**Por qué estas fuentes.** Raleway les da personalidad a los títulos sin perder seriedad académica. DM Sans se lee bien en tamaños pequeños, que es casi todo el texto de la app. DM Mono se usa solo para cifras, para que las notas queden alineadas.

### Espacios (`SfSpacing`) y radios (`SfRadius`)

- Espacios: `xxs 4 · xs 8 · sm 12 · md 16 · screen 18 · lg 24 · xl 32 · xxl 48`. El margen lateral de todas las pantallas es `screen` (18).
- Radios: `sm 8` (insignias) · `md 12` (campos, filas, selectores) · `lg 16` (tarjetas, botones) · `sheet 28` (hojas inferiores) · `pill` (solo chips de filtro).

## Componentes

| Componente | Para qué | Ejemplo en Figma |
| --- | --- | --- |
| `SfButton` | Botón: `primary`, `secondary`, `ghost`, `danger`, con carga | "Guardar tarea", "Seguir con el plan gratis" |
| `SfIconButton` | Botón redondo con ícono; puede llevar punto de aviso | Atrás, cerrar, campana |
| `SfFab` | Botón flotante de agregar | "+" en Inicio, Calendario y Tareas |
| `SfCard` | Tarjeta plana; `highlighted` para lo más importante | "Tu plan de hoy" |
| `SfTextField` | Campo de texto con etiqueta; `isPassword` trae el ojo | Registro, login |
| `SfPickerField` + `sfPickDate` / `sfPickTime` | Campo que abre el calendario o el reloj | Fecha y hora de entrega |
| `sfFormatDate` / `sfFormatTime` | "mié 23 sep" y "6:00 p. m." | Subtítulos de tareas |
| `SfOptionCards` | Selector de tarjetas (reemplaza desplegables) | Tipo, materia, canal, método de pago |
| `SfSegmented` | Selector de 2 a 4 opciones cortas | Mensual / Semestre |
| `SfChip`, `SfChipBar` | Filtros en píldora | Todas / Hoy / Esta semana |
| `SfBadge`, `SfBadge.priority` | Estado real: prioridad, vencida, completada | "Alta", "Media" |
| `SfTaskTile` | Fila de actividad con su círculo para completar | Prioridades de hoy |
| `SfCheckCircle` | Círculo para completar, con el color de la materia | Lista de tareas |
| `SfStatCard` | Dato corto | "4 entregas esta semana" |
| `SfProgressBar`, `SfProgressRing` | Progreso lineal o en anillo | Progreso semanal, nota de la materia |
| `SfAvatar` | Inicial del nombre (no se inventan fotos) | Perfil |
| `SfScreenHeader` | Barra superior con atrás, título y acción | Materia, Nueva tarea |
| `SfLargeTitle` | Título grande de pestaña | Calendario, Tareas |
| `SfSectionHeader` | Encabezado de sección con "Ver todas" | Prioridades de hoy |
| `SfBottomNav` | Barra inferior | Las 5 pestañas |
| `showSfBottomSheet` | Abre una hoja inferior | S1 a S11 |
| `SfResultSheet` | Contenido de hoja de resultado | Tarea completada, Plan agregado |
| `SfEmptyState`, `SfLoadingState`, `SfErrorState` | Estados de una lista | Inicio vacío, asistente sin conexión |

## Datos de ejemplo

En el Sprint 1 solo se hace interfaz. Para que todas las pantallas cuenten la misma historia (Santiago, sus materias y sus tareas), usen `lib/core/demo/demo_data.dart`. En el Sprint 2 eso se reemplaza por datos de Supabase.
