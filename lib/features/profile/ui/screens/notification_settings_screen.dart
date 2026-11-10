import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studyflow/core/data/data.dart';
import 'package:studyflow/core/design_system/design_system.dart';
import 'package:studyflow/features/profile/ui/bloc/notification_settings_cubit.dart';
import 'package:studyflow/features/profile/ui/widgets/notification_setting_card.dart';

/// Ajustes de notificaciones (Figma 26). El Cubit se crea en profile_routes.dart.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SfScreenHeader(title: 'Ajustes de notificaciones'),
            Expanded(
              child:
                  BlocConsumer<
                    NotificationSettingsCubit,
                    NotificationSettingsState
                  >(
                    listenWhen: (antes, ahora) =>
                        antes.avisoId != ahora.avisoId ||
                        (ahora.estado == EstadoAjustes.guardado &&
                            antes.estado != EstadoAjustes.guardado),
                    listener: (context, state) {
                      if (state.estado == EstadoAjustes.guardado) {
                        Navigator.pop(context);
                      } else if (state.aviso != null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.aviso!)));
                      }
                    },
                    builder: (context, state) {
                      final ajustes = state.ajustes;
                      if (state.estado == EstadoAjustes.cargando) {
                        return const Center(
                          child: SfLoadingState(
                            message: 'Cargando tus ajustes',
                          ),
                        );
                      }
                      if (ajustes == null) {
                        return Center(
                          child: SingleChildScrollView(
                            child: SfErrorState(
                              message:
                                  state.mensaje ??
                                  'No pudimos cargar tus ajustes.',
                              onRetry: () => context
                                  .read<NotificationSettingsCubit>()
                                  .cargar(),
                            ),
                          ),
                        );
                      }
                      return _SettingsForm(
                        ajustes: ajustes,
                        guardando: state.estado == EstadoAjustes.guardando,
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsForm extends StatelessWidget {
  const _SettingsForm({required this.ajustes, required this.guardando});

  final AjustesNotificacion ajustes;
  final bool guardando;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationSettingsCubit>();
    void cambiar(AjustesNotificacion nuevos) => cubit.cambiar(nuevos);

    Future<void> elegirHora(Hora actual, ValueChanged<Hora> alElegir) async {
      final elegida = await sfPickTime(
        context,
        initial: TimeOfDay(hour: actual.hora, minute: actual.minuto),
      );
      if (elegida != null) alElegir(Hora(elegida.hour, elegida.minute));
    }

    String textoHora(Hora hora) =>
        sfFormatTime(TimeOfDay(hour: hora.hora, minute: hora.minuto));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SfSpacing.screen,
        SfSpacing.xs,
        SfSpacing.screen,
        SfSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Elige qué te avisamos y cuándo.',
            style: SfTypography.body.copyWith(color: SfColors.textSecondary),
          ),
          const SizedBox(height: SfSpacing.md),
          NotificationSettingCard(
            icon: Icons.assignment_outlined,
            title: 'Entregas',
            subtitle: 'Antes de que venza una tarea o un examen',
            enabled: ajustes.recordatorioEntregas,
            onChanged: (valor) =>
                cambiar(ajustes.copyWith(recordatorioEntregas: valor)),
            children: [
              Text('Días antes', style: SfTypography.label),
              SfSegmented<int>(
                segments: const [(1, '1 día'), (2, '2 días'), (3, '3 días')],
                selected: ajustes.diasAntes,
                onChanged: (valor) =>
                    cambiar(ajustes.copyWith(diasAntes: valor)),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Avisar también el mismo día',
                      style: SfTypography.bodyStrong,
                    ),
                  ),
                  Switch(
                    value: ajustes.avisoMismoDia,
                    onChanged: (valor) =>
                        cambiar(ajustes.copyWith(avisoMismoDia: valor)),
                  ),
                ],
              ),
              if (ajustes.avisoMismoDia) ...[
                Text('Horas antes', style: SfTypography.label),
                SfSegmented<int>(
                  segments: const [(1, '1 h'), (3, '3 h'), (6, '6 h')],
                  selected: ajustes.horasAntes,
                  onChanged: (valor) =>
                      cambiar(ajustes.copyWith(horasAntes: valor)),
                ),
              ],
            ],
          ),
          const SizedBox(height: SfSpacing.sm),
          NotificationSettingCard(
            icon: Icons.timer_outlined,
            title: 'Bloques de estudio',
            subtitle: 'Antes de empezar cada bloque',
            enabled: ajustes.avisoBloques,
            onChanged: (valor) =>
                cambiar(ajustes.copyWith(avisoBloques: valor)),
            children: [
              Text('Minutos antes', style: SfTypography.label),
              SfSegmented<int>(
                segments: const [(5, '5 min'), (15, '15 min'), (30, '30 min')],
                selected: ajustes.minutosAntesBloque,
                onChanged: (valor) =>
                    cambiar(ajustes.copyWith(minutosAntesBloque: valor)),
              ),
            ],
          ),
          const SizedBox(height: SfSpacing.sm),
          NotificationSettingCard(
            icon: Icons.wb_sunny_outlined,
            title: 'Plan del día',
            subtitle: 'Lo que tienes para hoy, cada mañana',
            enabled: ajustes.planDelDia,
            onChanged: (valor) => cambiar(ajustes.copyWith(planDelDia: valor)),
            children: [
              SfPickerField(
                label: 'Hora del aviso',
                icon: Icons.schedule_rounded,
                value: textoHora(ajustes.horaPlan),
                onTap: () => elegirHora(
                  ajustes.horaPlan,
                  (hora) => cambiar(ajustes.copyWith(horaPlan: hora)),
                ),
              ),
            ],
          ),
          const SizedBox(height: SfSpacing.sm),
          NotificationSettingCard(
            icon: Icons.insights_outlined,
            title: 'Resumen semanal',
            subtitle: 'Cómo te fue y qué viene la próxima semana',
            enabled: ajustes.resumenSemanal,
            onChanged: (valor) =>
                cambiar(ajustes.copyWith(resumenSemanal: valor)),
            children: [
              Text('Día', style: SfTypography.label),
              SfSegmented<int>(
                segments: const [
                  (DateTime.sunday, 'Domingo'),
                  (DateTime.monday, 'Lunes'),
                ],
                selected: ajustes.diaResumen,
                onChanged: (valor) =>
                    cambiar(ajustes.copyWith(diaResumen: valor)),
              ),
              SfPickerField(
                label: 'Hora del aviso',
                icon: Icons.schedule_rounded,
                value: textoHora(ajustes.horaResumen),
                onTap: () => elegirHora(
                  ajustes.horaResumen,
                  (hora) => cambiar(ajustes.copyWith(horaResumen: hora)),
                ),
              ),
            ],
          ),
          const SizedBox(height: SfSpacing.lg),
          SfButton(
            label: 'Guardar cambios',
            isLoading: guardando,
            onPressed: guardando ? null : cubit.guardar,
          ),
        ],
      ),
    );
  }
}
