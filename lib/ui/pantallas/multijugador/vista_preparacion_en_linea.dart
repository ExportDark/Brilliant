import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../modelo/mapa.dart';
import '../../../multijugador/modelos.dart';
import '../../../multijugador/sala_bloc.dart';
import '../../../multijugador/sala_event.dart';
import '../pantalla_preparacion.dart';
import 'lista_de_jugadores.dart';

/// La preparación en línea, cuando todavía no repartí mis números: la pantalla de
/// preparación de siempre, entera, que al confirmar manda el reparto al servidor. Si
/// pasan 60 segundos, el servidor reparte al azar.
class PreparacionEnLinea extends StatelessWidget {
  final VistaDeSala sala;

  const PreparacionEnLinea({super.key, required this.sala});

  @override
  Widget build(BuildContext context) {
    final tiempo = sala.segundosRestantes;
    final mapa = mapas.firstWhere((m) => m.nivel == sala.nivel);

    return PantallaPreparacion(
      mapa: mapa,
      titulo:
          'Reparte tus números${tiempo == null ? '' : ' · ${tiempo.ceil()} s'}',
      alConfirmar: (valores) => context.read<SalaBloc>().add(
        PreparacionEnviada({
          for (final MapEntry(:key, :value) in valores.entries)
            key.notacion: value,
        }),
      ),
    );
  }
}

/// La preparación en línea, cuando ya repartí: espero a los demás.
class VistaPreparacionEnLinea extends StatelessWidget {
  final VistaDeSala sala;

  const VistaPreparacionEnLinea({super.key, required this.sala});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final tiempo = sala.segundosRestantes;
    final cuenta = tiempo == null ? '' : ' · ${tiempo.ceil()} s';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          sala.yo.activo
              ? 'Listo. Esperando a los demás…$cuenta'
              : 'Quedaste fuera de la partida.',
          key: const ValueKey('esperando-la-preparacion'),
          textAlign: TextAlign.center,
          style: textos.titleMedium,
        ),
        const SizedBox(height: 16),
        ListaDeJugadores(
          jugadores: sala.jugadores,
          yo: sala.yo.usuario,
          conListo: true,
        ),
      ],
    );
  }
}
