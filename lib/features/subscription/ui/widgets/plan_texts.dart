import 'package:flutter/material.dart';

import 'package:studyflow/core/data/data.dart';

/// Una fila de la tabla Gratis vs Plus.
class PlanFeature {
  const PlanFeature(this.name, this.free, this.plus);

  final String name;

  /// Texto de la columna, o null para mostrar una marca de "incluido".
  final String? free;
  final String? plus;
}

/// Lo que incluye cada plan (texto fijo del producto, Figma 30).
const planFeatures = <PlanFeature>[
  PlanFeature('Consultas a la IA', '5 a la semana', 'Ilimitadas'),
  PlanFeature('Orden sugerido de tareas', null, null),
  PlanFeature('Agregar el plan al calendario', null, null),
  PlanFeature('Orden de respaldo sin conexión', null, null),
];

/// Cómo se ve cada método de pago (Figma 32). Solo se elige el método: los
/// datos los pide la pasarela, nunca StudyFlow.
({String label, String subtitle, IconData icon}) textosMetodo(
  MetodoPago metodo,
) => switch (metodo) {
  MetodoPago.tarjeta => (
    label: 'Tarjeta',
    subtitle: 'Débito o crédito',
    icon: Icons.credit_card_rounded,
  ),
  MetodoPago.pse => (
    label: 'PSE',
    subtitle: 'Desde tu cuenta bancaria',
    icon: Icons.account_balance_outlined,
  ),
  MetodoPago.nequi => (
    label: 'Nequi',
    subtitle: 'Desde tu celular',
    icon: Icons.smartphone_rounded,
  ),
};
