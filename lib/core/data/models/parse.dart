// Ayudas para leer las filas que devuelve Supabase (Map<String, dynamic>).

/// timestamptz → DateTime en la hora local del celular.
DateTime fecha(Object? value) => DateTime.parse(value! as String).toLocal();

/// Igual que [fecha], pero acepta nulo.
DateTime? fechaONula(Object? value) => value == null ? null : fecha(value);

/// Columna `date` (sin hora): '2026-11-10' → DateTime(2026, 11, 10).
DateTime dia(Object? value) => DateTime.parse(value! as String);

DateTime? diaONulo(Object? value) => value == null ? null : dia(value);

/// DateTime → '2026-11-10' para columnas `date`.
String diaDb(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

/// numeric → double (Supabase lo puede mandar como int o como double).
double numero(Object? value) => (value! as num).toDouble();

double? numeroONulo(Object? value) => value == null ? null : numero(value);

/// Relación uno a uno anidada en un select: `materias(nombre)` llega como Map.
Map<String, dynamic>? anidado(Object? value) => value is Map<String, dynamic> ? value : null;

/// Relación uno a muchos anidada: `horarios_clase(*)` llega como List.
List<Map<String, dynamic>> lista(Object? value) =>
    value is List ? value.cast<Map<String, dynamic>>() : const [];
