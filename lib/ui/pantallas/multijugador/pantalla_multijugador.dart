import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../animacion/iris.dart';
import '../../../multijugador/cliente_salas.dart';
import '../../../multijugador/modelos.dart';
import '../../../multijugador/sala_bloc.dart';
import '../../../multijugador/sala_event.dart';
import '../../../multijugador/sala_state.dart';
import '../../../modelo/mapa.dart';
import 'confirmar_salida.dart';
import '../../widgets/hoja_de_reglas.dart';
import '../../widgets/recuadro_de_aviso.dart';
import 'vista_lobby.dart';
import 'vista_partida_en_linea.dart';
import 'vista_preparacion_en_linea.dart';
import 'vista_resultado.dart';
import 'vista_sin_sala.dart';
import '../../widgets/piezas.dart';

/// El multijugador: crear o unirse a una sala, el lobby, la preparación, la partida y el
/// resultado, todo en esta pantalla según en qué va la sala (lo decide el servidor).
///
/// Se abre desde "Elige un mapa". Salirse a mitad de una partida pide confirmación, y
/// equivale a rendirse.
class PantallaMultijugador extends StatelessWidget {
  /// Cada cuánto se le pregunta al servidor cómo va la sala. Los tests lo cambian o
  /// lo apagan.
  final Duration? intervalo;

  /// La hora, para contar cuánto lleva el servidor sin contestar. Los tests la cambian.
  final DateTime Function()? ahora;

  const PantallaMultijugador({
    super.key,
    this.intervalo = const Duration(seconds: 1),
    this.ahora,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalaBloc(
        context.read<ClienteSalas>(),
        intervalo: intervalo,
        ahora: ahora,
      ),
      child: const _Cuerpo(),
    );
  }
}

class _Cuerpo extends StatelessWidget {
  const _Cuerpo();

  /// Si salir de la pantalla tiene que pasar por el servidor: en una sala que no terminó,
  /// mientras el jugador sigue en ella. Quien ya quedó fuera (se rindió o se desconectó)
  /// sale sin más.
  static bool _salirPasaPorElServidor(SalaState state) {
    final vista = state.vista;
    return state.enSala &&
        vista != null &&
        vista.estado != EstadoDeSala.terminada &&
        vista.yo.activo;
  }

  /// Sale de la sala desde la flecha de atrás: en el lobby, el invitado sale de una vez y
  /// el anfitrión confirma (cierra la sala para todos); en el reparto o la partida, se
  /// pregunta si rendirse. Cada pedido lleva el estado que se estaba viendo.
  static Future<void> _salir(BuildContext context, VistaDeSala sala) async {
    final bloc = context.read<SalaBloc>();
    if (sala.estado == EstadoDeSala.esperando) {
      if (sala.soyElAnfitrion && !await confirmarCerrarSala(context)) return;
      bloc.add(const Rendirse(desde: EstadoDeSala.esperando));
      return;
    }
    if (await confirmarRendirse(context)) bloc.add(Rendirse(desde: sala.estado));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SalaBloc, SalaState>(
      // Quien se va por su cuenta vuelve directo a "Elige un mapa", aunque haya un
      // diálogo o la hoja de reglas abierta. Se espera a que se redibuje, para que la
      // pantalla ya deje salir.
      listenWhen: (antes, ahora) =>
          antes.fin != FinDeSala.teFuiste && ahora.fin == FinDeSala.teFuiste,
      listener: (context, _) =>
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).popUntil((ruta) => ruta.isFirst);
            }
          }),
      builder: (context, state) {
        return PopScope(
          canPop: !_salirPasaPorElServidor(state),
          onPopInvokedWithResult: (salio, _) {
            if (!salio) _salir(context, state.vista!);
          },
          child: _repartiendo(state)
              ? Stack(
                  key: const ValueKey('preparacion-en-linea'),
                  children: [
                    PreparacionEnLinea(sala: state.vista!),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: SafeArea(
                        child: Material(
                          type: MaterialType.transparency,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (state.conexion != Conexion.conectada)
                                RecuadroDeAviso(
                                  state.conexion == Conexion.reconectando
                                      ? 'Reconectando con el servidor…'
                                      : 'Se perdió la conexión. Si no vuelve, quedas fuera de '
                                            'la partida.',
                                  key: const ValueKey('aviso-de-conexion'),
                                  icono: Icons.wifi_off_rounded,
                                ),
                              if (state.error != null)
                                RecuadroDeAviso(
                                  state.error!,
                                  key: const ValueKey('error-de-sala'),
                                  icono: Icons.error_outline_rounded,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              // Los momentos clave, con el iris, sobre toda la pantalla (también la
              // barra de arriba): se abre al empezar la partida (aunque llegue de golpe,
              // sin pasar por la espera) y se cierra sobre el trofeo al terminar.
              : Iris.cierre(
                  disparador: _conResultado(state) ? state.vista!.codigo : null,
                  child: Iris.apertura(
                    disparador: state.vista?.estado == EstadoDeSala.jugando
                        ? state.vista!.codigo
                        : null,
                    alAparecer: true,
                    child: Scaffold(
                      appBar: AppBar(
                        title: const Text('Multijugador'),
                        actions: [
                          // En la partida, las reglas del mapa que se está jugando.
                          if (state.enSala &&
                              state.vista!.estado == EstadoDeSala.jugando)
                            BotonDeReglas(
                              mapa: mapas.firstWhere(
                                (m) => m.nivel == state.vista!.nivel,
                              ),
                              enLinea: true,
                              meta: state.vista!.meta,
                            ),
                        ],
                      ),
                      body: SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                          child: Center(
                            child: Bandeja(
                              anchoMaximo: 480,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (state.enSala &&
                                      state.conexion != Conexion.conectada)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: RecuadroDeAviso(
                                        state.conexion == Conexion.reconectando
                                            ? 'Reconectando con el servidor…'
                                            : 'Se perdió la conexión. Si no vuelve, quedas fuera de la '
                                                  'partida.',
                                        key: const ValueKey(
                                          'aviso-de-conexion',
                                        ),
                                        icono: Icons.wifi_off_rounded,
                                      ),
                                    ),
                                  if (state.error != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: RecuadroDeAviso(
                                        state.error!,
                                        key: const ValueKey('error-de-sala'),
                                        icono: Icons.error_outline_rounded,
                                      ),
                                    ),
                                  _contenido(context, state),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  /// Si la partida terminó con un resultado que mostrar (no si se cerró el lobby).
  static bool _conResultado(SalaState state) =>
      state.fin == FinDeSala.ninguno &&
      state.vista?.estado == EstadoDeSala.terminada &&
      state.vista?.resultado != null;

  /// Si me toca repartir mis números: esa pantalla ocupa todo, como en un jugador.
  static bool _repartiendo(SalaState state) {
    final sala = state.vista;
    return state.enSala &&
        sala != null &&
        sala.estado == EstadoDeSala.preparando &&
        sala.yo.activo &&
        !sala.yo.preparado;
  }

  Widget _contenido(BuildContext context, SalaState state) {
    if (state.fin != FinDeSala.ninguno) return _FinDeSala(fin: state.fin);
    final sala = state.vista;
    if (sala == null) return const VistaSinSala();

    return switch (sala.estado) {
      EstadoDeSala.esperando => VistaLobby(sala: sala),
      EstadoDeSala.preparando => VistaPreparacionEnLinea(sala: sala),
      EstadoDeSala.jugando => VistaPartidaEnLinea(sala: sala),
      EstadoDeSala.terminada =>
        sala.resultado == null
            ? const _FinDeSala(fin: FinDeSala.saliste)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VistaResultado(sala: sala),
                  const SizedBox(height: 16),
                  PiezaPresionable(
                    child: FilledButton(
                      key: const ValueKey('boton-volver'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Salir'),
                    ),
                  ),
                ],
              ),
    };
  }
}

/// Cuando ya no se está en la sala: salió, el servidor la cerró, o se reinició.
class _FinDeSala extends StatelessWidget {
  final FinDeSala fin;

  const _FinDeSala({required this.fin});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          switch (fin) {
            FinDeSala.desaparecio =>
              'La sala ya no existe: el servidor se reinició o la cerró.',
            FinDeSala.cerrada => 'El anfitrión cerró la sala.',
            FinDeSala.teFuiste => 'Saliste de la sala.',
            _ => 'Ya no estás en la sala.',
          },
          key: const ValueKey('fin-de-la-sala'),
          textAlign: TextAlign.center,
          style: textos.titleMedium,
        ),
        const SizedBox(height: 24),
        PiezaPresionable(
          child: FilledButton(
            key: const ValueKey('boton-volver'),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Volver'),
          ),
        ),
      ],
    );
  }
}
