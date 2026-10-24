/// Nombres de todas las rutas. El número es el de la pantalla en Figma.
///
/// Las pestañas (Inicio 12, Calendario 20, Tareas 17, Materias 21, Perfil 25)
/// no son rutas: viven dentro de [main], que recibe el índice de la pestaña.
/// Las hojas inferiores (S1 a S11) tampoco: se abren con showSfBottomSheet.
abstract final class AppRoutes {
  // Persona 1 · Acceso
  static const splash = '/'; // 01
  static const onboarding = '/onboarding'; // 02 y 03
  static const register = '/registro'; // 04
  static const login = '/login'; // 05
  static const forgotPassword = '/recuperar'; // 06
  static const emailSent = '/recuperar/enviado'; // 07

  // Contenedor con la barra inferior. Argumento: índice de la pestaña (int).
  static const main = '/app';

  // Persona 2 · Configuración y materias
  static const setupSubjects = '/configuracion/materias'; // 08
  static const newSubject = '/materias/nueva'; // 09 y S9
  static const setupReminders = '/configuracion/recordatorios'; // 10
  static const subjectDetail = '/materias/detalle'; // 22
  static const registerGrade = '/materias/nota'; // 23 y S3

  // Persona 3 · Inicio y tareas
  static const notifications = '/notificaciones'; // 13
  static const taskDetail = '/tareas/detalle'; // 18, S1, S2 y S8
  static const examDetail = '/examenes/detalle'; // 29

  // Persona 4 · Formularios de tarea, calendario y bloques
  static const newTask = '/tareas/nueva'; // 14
  static const taskSaved = '/tareas/guardada'; // 15
  static const editTask = '/tareas/editar'; // 19
  static const studyBlock = '/bloques/detalle'; // 27, S5 y S10
  static const newStudyBlock = '/bloques/nuevo'; // 28

  // Persona 5 · Asistente, perfil y Plus
  static const assistant = '/asistente'; // 24, S4 y 31
  static const notificationSettings = '/perfil/notificaciones'; // 26
  static const plus = '/plus'; // 30
  static const payment = '/plus/pago'; // 32 y S11

  // Desarrollo: índice de pantallas y galería del design system.
  static const devMenu = '/dev';
  static const designSystem = '/dev/design-system';
}

/// Índices de las pestañas de [AppRoutes.main].
abstract final class AppTabs {
  static const home = 0;
  static const calendar = 1;
  static const tasks = 2;
  static const subjects = 3;
  static const profile = 4;
}
