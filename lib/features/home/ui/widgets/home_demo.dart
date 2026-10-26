import 'package:studyflow/core/demo/demo_data.dart';

/// Los tres estados de Inicio que muestra el prototipo.
enum HomeVariant {
  /// Figma 11: aún no hay entregas.
  empty,

  /// Figma 12: el día normal, con un bloque de ayer sin completar.
  normal,

  /// Figma 16: después de guardar "Prototipo flujo principal".
  updated,
}

/// Datos de Inicio que no están en DemoData. Salen tal cual de Figma 11, 12
/// y 16; en el Sprint 2 se calculan con los datos de Supabase.
abstract final class HomeDemo {
  static const today = 'Lunes, 21 de septiembre';

  /// La tarea que se guarda entre Figma 12 y 16.
  static const savedTaskTitle = 'Prototipo flujo principal';

  static const plan =
      'Empieza por la Lectura capítulo 4 antes de las 6:00 p. m. y luego el Taller 3 de SQL. '
      'Reserva 2 h para el parcial del jueves.';

  static String deliveries(HomeVariant variant) => switch (variant) {
        HomeVariant.empty => '0',
        HomeVariant.normal => '3',
        HomeVariant.updated => '4',
      };

  /// Tareas hechas y totales de la semana: "5 de 9 tareas".
  static (int, int) weekProgress(HomeVariant variant) => switch (variant) {
        HomeVariant.empty => (0, 0),
        HomeVariant.normal => (5, 9),
        HomeVariant.updated => (5, 10),
      };

  /// Pendientes que vencen hoy.
  static List<DemoTask> todayTasks(HomeVariant variant) => [
        if (variant != HomeVariant.empty)
          for (final task in DemoData.tasks)
            if (!task.done && task.due.startsWith('hoy')) task,
      ];

  /// Pendientes de los próximos días. La tarea guardada solo aparece en 16.
  static List<DemoTask> upcomingTasks(HomeVariant variant) => [
        if (variant != HomeVariant.empty)
          for (final task in DemoData.tasks)
            if (!task.done &&
                !task.due.startsWith('hoy') &&
                (variant == HomeVariant.updated || task.title != savedTaskTitle))
              task,
      ];
}
