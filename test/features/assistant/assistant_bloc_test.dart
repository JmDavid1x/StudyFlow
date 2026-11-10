import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/features/assistant/domain/assistant_repository.dart';
import 'package:studyflow/features/assistant/domain/limite_consultas.dart';
import 'package:studyflow/features/assistant/ui/bloc/assistant_bloc.dart';
import 'package:studyflow/features/subscription/domain/subscription_repository.dart';

import 'fixtures.dart';

class _MockAssistantRepository extends Mock implements AssistantRepository {}

class _MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

void main() {
  late _MockAssistantRepository repo;
  late _MockSubscriptionRepository suscripciones;
  // Martes 10 de noviembre de 2026, 10:00 a. m.
  final ahora = DateTime(2026, 11, 10, 10);
  final pendientes = [
    actividad('taller', fecha: DateTime(2026, 11, 10, 23, 59)),
    actividad(
      'parcial',
      fecha: DateTime(2026, 11, 12, 8),
      tipo: TipoActividad.examen,
    ),
  ];
  var siguienteId = 0;

  AssistantBloc crear() =>
      AssistantBloc(repo, suscripciones, reloj: () => ahora);

  /// Guarda el mensaje "en la base": lo devuelve con un id nuevo.
  void guardarMensajes() {
    when(
      () => repo.enviarMensaje(
        rol: any(named: 'rol'),
        contenido: any(named: 'contenido'),
        usadoRespaldo: any(named: 'usadoRespaldo'),
      ),
    ).thenAnswer((invocacion) async {
      final args = invocacion.namedArguments;
      return mensaje(
        'm${siguienteId++}',
        creadoEn: ahora,
        rol: args[#rol] as RolMensaje,
        contenido: args[#contenido] as String,
        usadoRespaldo: (args[#usadoRespaldo] as bool?) ?? false,
      );
    });
  }

  setUpAll(() {
    registerFallbackValue(RolMensaje.usuario);
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(<Actividad>[]);
  });

  setUp(() {
    siguienteId = 0;
    repo = _MockAssistantRepository();
    suscripciones = _MockSubscriptionRepository();
    when(() => repo.historial()).thenAnswer((_) async => []);
    when(
      () => repo.actividadesPendientes(),
    ).thenAnswer((_) async => pendientes);
    when(
      () => repo.responderConIA(any(), any()),
    ).thenThrow(const IaNoDisponible());
    when(
      () => suscripciones.suscripcionVigente(),
    ).thenAnswer((_) async => null);
    guardarMensajes();
  });

  group('al abrir', () {
    blocTest<AssistantBloc, AssistantState>(
      'carga la conversación y cuenta las consultas de la semana',
      setUp: () => when(() => repo.historial()).thenAnswer(
        (_) async => [
          mensaje('a', creadoEn: DateTime(2026, 11, 9, 8)),
          mensaje('b', creadoEn: DateTime(2026, 11, 10, 8)),
          mensaje(
            'c',
            creadoEn: DateTime(2026, 11, 10, 9),
            usadoRespaldo: true,
          ),
        ],
      ),
      build: crear,
      act: (bloc) => bloc.add(const AsistenteIniciado()),
      expect: () => [
        isA<AssistantState>().having(
          (s) => s.estado,
          'estado',
          EstadoAsistente.cargando,
        ),
        isA<AssistantState>()
            .having((s) => s.estado, 'estado', EstadoAsistente.listo)
            .having((s) => s.mensajes.length, 'mensajes', 3)
            .having((s) => s.limite.etiqueta, 'contador', '2 de 5 gratis'),
      ],
    );

    blocTest<AssistantBloc, AssistantState>(
      'si no puede cargar queda en error',
      setUp: () => when(
        () => repo.historial(),
      ).thenThrow(const AppException('Sin conexión.')),
      build: crear,
      act: (bloc) => bloc.add(const AsistenteIniciado()),
      skip: 1,
      expect: () => [
        isA<AssistantState>()
            .having((s) => s.estado, 'estado', EstadoAsistente.error)
            .having((s) => s.mensaje, 'mensaje', 'Sin conexión.'),
      ],
    );
  });

  group('al preguntar', () {
    blocTest<AssistantBloc, AssistantState>(
      'sin IA responde con el orden de respaldo y no gasta consulta',
      build: crear,
      seed: () => const AssistantState(estado: EstadoAsistente.listo),
      act: (bloc) => bloc.add(const PreguntaEnviada('¿Qué hago hoy?')),
      expect: () => [
        isA<AssistantState>().having((s) => s.enviando, 'enviando', isTrue),
        isA<AssistantState>()
            .having((s) => s.enviando, 'enviando', isFalse)
            .having((s) => s.mensajes.map((m) => m.rol).toList(), 'roles', [
              RolMensaje.usuario,
              RolMensaje.asistente,
            ])
            .having((s) => s.mensajes.last.usadoRespaldo, 'respaldo', isTrue)
            .having(
              (s) => s.orden!.map((i) => i.actividad.id).toList(),
              'orden',
              ['taller', 'parcial'],
            )
            .having((s) => s.respuestaId, 'respuesta', 'm1')
            .having((s) => s.limite.usadas, 'usadas', 0),
      ],
      verify: (_) => verify(
        () => repo.responderConIA('¿Qué hago hoy?', pendientes),
      ).called(1),
    );

    blocTest<AssistantBloc, AssistantState>(
      'sin consultas gratis ni siquiera intenta con la IA',
      build: crear,
      seed: () => const AssistantState(
        estado: EstadoAsistente.listo,
        limite: LimiteConsultas(usadas: 5, esPlus: false),
      ),
      act: (bloc) => bloc.add(const PreguntaEnviada('Organiza mi semana')),
      skip: 1,
      expect: () => [
        isA<AssistantState>().having(
          (s) => s.mensajes.last.contenido,
          'contenido',
          startsWith('Ya usaste tus consultas gratis'),
        ),
      ],
      verify: (_) => verifyNever(() => repo.responderConIA(any(), any())),
    );

    blocTest<AssistantBloc, AssistantState>(
      'si no puede guardar la pregunta, avisa',
      setUp: () => when(
        () => repo.enviarMensaje(
          rol: any(named: 'rol'),
          contenido: any(named: 'contenido'),
          usadoRespaldo: any(named: 'usadoRespaldo'),
        ),
      ).thenThrow(const AppException('Sin conexión.')),
      build: crear,
      seed: () => const AssistantState(estado: EstadoAsistente.listo),
      act: (bloc) => bloc.add(const PreguntaEnviada('Hola')),
      skip: 1,
      expect: () => [
        isA<AssistantState>()
            .having((s) => s.enviando, 'enviando', isFalse)
            .having((s) => s.aviso, 'aviso', 'Sin conexión.'),
      ],
    );
  });

  blocTest<AssistantBloc, AssistantState>(
    'reintentar sin IA avisa y no guarda nada',
    build: crear,
    seed: () => AssistantState(
      estado: EstadoAsistente.listo,
      mensajes: [
        mensaje(
          'p',
          creadoEn: ahora,
          rol: RolMensaje.usuario,
          contenido: '¿Qué hago hoy?',
        ),
      ],
    ),
    act: (bloc) => bloc.add(const ReintentoPedido()),
    skip: 1,
    expect: () => [
      isA<AssistantState>()
          .having((s) => s.mensajes.length, 'mensajes', 1)
          .having(
            (s) => s.aviso,
            'aviso',
            startsWith('El asistente sigue sin responder'),
          ),
    ],
  );

  group('agregar al plan', () {
    setUp(() {
      when(() => repo.planActivo()).thenAnswer((_) async => null);
      when(
        () => repo.horariosDeClase(),
      ).thenAnswer((_) async => [clase(DateTime.tuesday, 11, 13)]);
      when(
        () => repo.bloquesPendientesDesde(any()),
      ).thenAnswer((_) async => []);
      when(
        () => repo.crearPlan(
          resumen: any(named: 'resumen'),
          usadoRespaldo: any(named: 'usadoRespaldo'),
          orden: any(named: 'orden'),
          bloques: any(named: 'bloques'),
          mensajeId: any(named: 'mensajeId'),
        ),
      ).thenAnswer(
        (_) async => PlanEstudio(
          id: 'plan1',
          perfilId: 'p1',
          tipo: TipoPlan.solicitado,
          resumen: 'Empieza por Actividad taller',
          usadoRespaldo: true,
          activo: true,
          creadoEn: ahora,
        ),
      );
    });

    blocTest<AssistantBloc, AssistantState>(
      'crea el plan con sus bloques y abre la hoja S4',
      build: crear,
      seed: () => const AssistantState(estado: EstadoAsistente.listo),
      act: (bloc) async {
        bloc.add(const PreguntaEnviada('¿Qué hago hoy?'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PlanPedido());
      },
      skip: 2,
      expect: () => [
        isA<AssistantState>().having((s) => s.agregando, 'agregando', isTrue),
        isA<AssistantState>()
            .having((s) => s.agregando, 'agregando', isFalse)
            .having((s) => s.planId, 'planId', 1)
            .having((s) => s.planAgregado!.plan.id, 'plan', 'plan1')
            .having((s) => s.planAgregado!.bloques.length, 'bloques', 2)
            // El taller va ya (10 a 11); la clase de 11 a 1 empuja el parcial a la 1.
            .having(
              (s) => s.planAgregado!.bloques.first.inicio,
              'primer bloque',
              DateTime(2026, 11, 10, 10),
            )
            .having(
              (s) => s.planAgregado!.bloques.last.inicio,
              'segundo bloque',
              DateTime(2026, 11, 10, 13),
            ),
      ],
      verify: (_) => verify(
        () => repo.crearPlan(
          resumen: any(named: 'resumen'),
          usadoRespaldo: true,
          orden: any(named: 'orden'),
          bloques: any(named: 'bloques'),
          mensajeId: 'm1',
        ),
      ).called(1),
    );

    blocTest<AssistantBloc, AssistantState>(
      'sin orden sugerido no hace nada',
      build: crear,
      seed: () => const AssistantState(estado: EstadoAsistente.listo),
      act: (bloc) => bloc.add(const PlanPedido()),
      expect: () => <AssistantState>[],
    );
  });
}
