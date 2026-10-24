import 'package:studyflow/core/navigation/app_routes.dart';
import 'package:studyflow/core/navigation/team.dart';

/// Una pantalla del prototipo y quién la construye.
class ScreenInfo {
  const ScreenInfo({
    required this.figma,
    required this.title,
    required this.route,
    required this.owner,
    this.tab,
  });

  /// Número en Figma: "12", "14", "S4".
  final String figma;
  final String title;
  final String route;
  final String owner;

  /// Si es una pestaña, su índice dentro de [AppRoutes.main].
  final int? tab;
}

/// Todas las pantallas del Sprint 1, en el orden del reparto.
const screenCatalog = <ScreenInfo>[
  ScreenInfo(figma: '01', title: 'Splash', route: AppRoutes.splash, owner: Team.p1),
  ScreenInfo(figma: '02-03', title: 'Onboarding', route: AppRoutes.onboarding, owner: Team.p1),
  ScreenInfo(figma: '04', title: 'Registro', route: AppRoutes.register, owner: Team.p1),
  ScreenInfo(figma: '05', title: 'Iniciar sesión', route: AppRoutes.login, owner: Team.p1),
  ScreenInfo(figma: '06', title: 'Recuperar contraseña', route: AppRoutes.forgotPassword, owner: Team.p1),
  ScreenInfo(figma: '07', title: 'Correo enviado', route: AppRoutes.emailSent, owner: Team.p1),
  ScreenInfo(figma: '08', title: 'Tus materias', route: AppRoutes.setupSubjects, owner: Team.p2),
  ScreenInfo(figma: '09 · S9', title: 'Nueva materia y horario', route: AppRoutes.newSubject, owner: Team.p2),
  ScreenInfo(figma: '10', title: 'Activar recordatorios', route: AppRoutes.setupReminders, owner: Team.p2),
  ScreenInfo(figma: '21', title: 'Materias', route: AppRoutes.main, owner: Team.p2, tab: AppTabs.subjects),
  ScreenInfo(figma: '22', title: 'Detalle de materia', route: AppRoutes.subjectDetail, owner: Team.p2),
  ScreenInfo(figma: '23 · S3', title: 'Registrar nota', route: AppRoutes.registerGrade, owner: Team.p2),
  ScreenInfo(figma: '11 · 12 · 16', title: 'Inicio', route: AppRoutes.main, owner: Team.p3, tab: AppTabs.home),
  ScreenInfo(figma: '13', title: 'Notificaciones', route: AppRoutes.notifications, owner: Team.p3),
  ScreenInfo(figma: '17', title: 'Tareas', route: AppRoutes.main, owner: Team.p3, tab: AppTabs.tasks),
  ScreenInfo(figma: '18 · S1 · S2 · S8', title: 'Detalle de tarea', route: AppRoutes.taskDetail, owner: Team.p3),
  ScreenInfo(figma: '29', title: 'Detalle de examen', route: AppRoutes.examDetail, owner: Team.p3),
  ScreenInfo(figma: '14', title: 'Nueva tarea', route: AppRoutes.newTask, owner: Team.p4),
  ScreenInfo(figma: '15', title: 'Tarea guardada', route: AppRoutes.taskSaved, owner: Team.p4),
  ScreenInfo(figma: '19', title: 'Editar tarea', route: AppRoutes.editTask, owner: Team.p4),
  ScreenInfo(figma: '20 · S7', title: 'Calendario', route: AppRoutes.main, owner: Team.p4, tab: AppTabs.calendar),
  ScreenInfo(figma: '27 · S5 · S10', title: 'Bloque de estudio', route: AppRoutes.studyBlock, owner: Team.p4),
  ScreenInfo(figma: '28', title: 'Nuevo bloque', route: AppRoutes.newStudyBlock, owner: Team.p4),
  ScreenInfo(figma: '24 · S4 · 31', title: 'Asistente', route: AppRoutes.assistant, owner: Team.p5),
  ScreenInfo(figma: '25', title: 'Perfil', route: AppRoutes.main, owner: Team.p5, tab: AppTabs.profile),
  ScreenInfo(figma: '26', title: 'Ajustes de notificaciones', route: AppRoutes.notificationSettings, owner: Team.p5),
  ScreenInfo(figma: '30', title: 'StudyFlow Plus', route: AppRoutes.plus, owner: Team.p5),
  ScreenInfo(figma: '32 · S11', title: 'Pago y prueba gratis', route: AppRoutes.payment, owner: Team.p5),
];
