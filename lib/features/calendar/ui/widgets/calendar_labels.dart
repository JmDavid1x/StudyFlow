/// Nombres en español para el calendario. Van aquí para no depender de un
/// paquete de fechas solo por esto.
abstract final class CalendarLabels {
  static const weekdaysShort = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
  static const months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  /// "Septiembre 2026"
  static String monthYear(DateTime date) => '${months[date.month - 1]} ${date.year}';

  /// "Lunes 21"
  static String dayTitle(DateTime date) => '${weekdays[date.weekday - 1]} ${date.day}';
}
