import 'package:flutter/material.dart';

import 'package:studyflow/features/study_blocks/ui/widgets/demo_agenda.dart';

/// Planes de StudyFlow Plus (Figma 30 y 32). Se le pasa a la ruta de pago
/// como argumento para que el resumen muestre el plan elegido.
enum PlusPlan {
  monthly('Mensual', 'COP 9.900', 'al mes'),
  semester('Semestre', 'COP 39.900', 'por semestre');

  const PlusPlan(this.label, this.price, this.period);

  final String label;
  final String price;
  final String period;
}

/// Una fila de la tabla Gratis vs Plus.
class PlanFeature {
  const PlanFeature(this.name, this.free, this.plus);

  final String name;

  /// Texto de la columna, o null para mostrar una marca de "incluido".
  final String? free;
  final String? plus;
}

/// Método de pago (Figma 32). Solo se elige el método: los datos los pide la
/// pasarela, nunca StudyFlow.
enum PaymentMethod {
  card('Tarjeta', 'Débito o crédito', Icons.credit_card_rounded),
  pse('PSE', 'Desde tu cuenta bancaria', Icons.account_balance_outlined),
  nequi('Nequi', 'Desde tu celular', Icons.smartphone_rounded);

  const PaymentMethod(this.label, this.subtitle, this.icon);

  final String label;
  final String subtitle;
  final IconData icon;
}

abstract final class SubscriptionDemo {
  static const trialDays = 7;

  /// La prueba empieza "hoy" en el prototipo, el mismo día que usa el
  /// Calendario, y el primer cobro es el día en que termina.
  static DateTime get trialEnd => DemoAgenda.today.add(const Duration(days: trialDays));

  static const features = <PlanFeature>[
    PlanFeature('Consultas al asistente', '5 a la semana', 'Ilimitadas'),
    PlanFeature('Orden sugerido de tareas', null, null),
    PlanFeature('Agregar el plan al calendario', null, null),
    PlanFeature('Orden de respaldo sin conexión', null, null),
  ];
}
