import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../modelo/mapa.dart';
import '../../../modelo/posicion.dart';
import '../../../modelo/tablero.dart';
import '../../../multijugador/modelos.dart';
import '../../../multijugador/sala_bloc.dart';
import '../../../multijugador/sala_event.dart';
import '../../tema.dart';
import '../../widgets/celda_widget.dart';
import '../../widgets/dado_widget.dart';
import '../../widgets/tablero_widget.dart';
import 'lista_de_jugadores.dart';
import 'panel_de_zonas.dart';

/// La partida en línea: **mi** tablero, los dos dados de la ronda (iguales para todos), la
/// cuenta regresiva, los puntos de cada jugador y el panel de zonas.
///
/// El servidor dice dónde se puede anotar con cada dado ancla; aquí solo se ilumina eso.
/// Nadie ve el tablero de otro jugador.
class VistaPartidaEnLinea extends StatefulWidget {
  final VistaDeSala sala;

  const VistaPartidaEnLinea({super.key, required this.sala});

  @override
  State<VistaPartidaEnLinea> createState() => _VistaPartidaEnLineaState();
}

class _VistaPartidaEnLineaState extends State<VistaPartidaEnLinea> {
  /// El número del dado ancla que eligió el jugador, o `null` si no ha elegido.
  int? _ancla;

  /// La ronda de la que es [_ancla]: al cambiar de ronda se olvida la elección.
  int _rondaDelAncla = 0;

  VistaDeSala get _sala => widget.sala;

  /// Los números que se pueden usar de ancla ahora: los que tienen dónde anotar.
  List<JugadaLegal> get _opciones => [
    for (final jugada in _sala.yo.jugadas)
      if (jugada.casillas.isNotEmpty) jugada,
  ];

  /// El ancla que vale: la elegida si sigue siendo posible; si solo hay una opción, esa.
  JugadaLegal? get _jugada {
    if (_rondaDelAncla != _sala.ronda) {
      return _opciones.length == 1 ? _opciones.single : null;
    }
    final elegida = _opciones.where((j) => j.ancla == _ancla).firstOrNull;
    if (elegida != null) return elegida;
    return _opciones.length == 1 ? _opciones.single : null;
  }

  void _elegirAncla(int numero) {
    setState(() {
      _ancla = numero;
      _rondaDelAncla = _sala.ronda;
    });
  }

  Future<void> _confirmarRendirse() async {
    final bloc = context.read<SalaBloc>();
    final seguro = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('¿Rendirte?'),
        content: const Text(
          'Quedarás fuera de la partida. Conservas los puntos que ya ganaste.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Seguir jugando'),
          ),
          FilledButton(
            key: const ValueKey('confirmar-rendirse'),
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Rendirme'),
          ),
        ],
      ),
    );
    if (seguro == true) bloc.add(const Rendirse());
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final sala = _sala;
    final yo = sala.yo;
    final mapa = mapas.firstWhere((m) => m.nivel == sala.nivel);
    final tablero = Tablero.desdeMapa(mapa).conValores({
      for (final MapEntry(:key, :value) in yo.tablero.entries)
        Posicion.desdeNotacion(key): value,
    });

    final jugada = _jugada;
    final puedeJugar = yo.puedeJugar;
    final legales = puedeJugar && jugada != null
        ? jugada.casillas.toSet()
        : const <String>{};
    final dados = sala.dados ?? const <int>[];
    final tiempo = context.select((SalaBloc bloc) => bloc.state.segundosQueQuedan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ronda ${sala.ronda}${tiempo == null ? '' : ' · ${tiempo.ceil()} s'}',
          key: const ValueKey('ronda-y-tiempo'),
          textAlign: TextAlign.center,
          style: textos.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final (indice, valor) in dados.indexed) ...[
              if (indice > 0) const SizedBox(width: 16),
              DadoWidget(
                key: ValueKey('dado-$indice'),
                valor: valor,
                anclado: jugada != null && jugada.ancla == valor,
                alTocar: puedeJugar && _opciones.any((o) => o.ancla == valor)
                    ? () => _elegirAncla(valor)
                    : null,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _indicacion(yo, jugada, puedeJugar),
          key: const ValueKey('indicacion'),
          textAlign: TextAlign.center,
          style: textos.bodyMedium?.copyWith(color: Paleta.tintaSuave),
        ),
        const SizedBox(height: 12),
        TableroWidget(
          tablero: tablero,
          esTocable: (posicion) => legales.contains(posicion.notacion),
          iluminacionDe: (posicion) => legales.contains(posicion.notacion)
              ? Iluminacion.posible
              : Iluminacion.normal,
          numeroResaltadoEn: (posicion) =>
              jugada != null &&
              tablero.celdaEn(posicion)?.valor == jugada.ancla,
          alTocar: (posicion) {
            final elegida = jugada;
            if (elegida == null) return;
            context.read<SalaBloc>().add(
              JugadaEnviada(
                dadoAncla: elegida.ancla,
                casilla: posicion.notacion,
              ),
            );
          },
        ),
        if (yo.puedePasar && yo.activo && yo.accion == 'pendiente')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton(
              key: const ValueKey('boton-pasar'),
              onPressed: () =>
                  context.read<SalaBloc>().add(const RondaPasada()),
              child: const Text('Pasar turno'),
            ),
          ),
        const SizedBox(height: 20),
        Text('Jugadores', style: textos.titleMedium),
        const SizedBox(height: 6),
        ListaDeJugadores(
          jugadores: sala.jugadores,
          yo: yo.usuario,
          conPuntos: true,
          conListo: true,
        ),
        const SizedBox(height: 20),
        PanelDeZonas(zonas: sala.zonas),
        if (yo.activo) ...[
          const SizedBox(height: 12),
          TextButton(
            key: const ValueKey('boton-rendirse'),
            style: TextButton.styleFrom(foregroundColor: Paleta.peligro),
            onPressed: _confirmarRendirse,
            child: const Text('Rendirme'),
          ),
        ],
      ],
    );
  }

  String _indicacion(MiVista yo, JugadaLegal? jugada, bool puedeJugar) {
    if (!yo.activo) return 'Quedaste fuera de la partida.';
    if (yo.accion == 'coloco') return 'Anotaste. Esperando a los demás…';
    if (yo.accion == 'paso') {
      return 'No tenías dónde anotar: pasaste esta ronda.';
    }
    if (!puedeJugar) return 'Esperando…';
    if (jugada == null) {
      return 'Toca un dado: es el ancla, el número que se busca en tu tablero.';
    }
    return 'Anota el ${jugada.valor} en una casilla iluminada.';
  }
}
