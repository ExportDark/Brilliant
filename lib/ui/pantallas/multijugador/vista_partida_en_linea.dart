import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../animacion/cartoon.dart';
import '../../../juego/validacion_jugada.dart';
import '../../../modelo/mapa.dart';
import '../../../modelo/posicion.dart';
import '../../../modelo/tablero.dart';
import '../../../multijugador/modelos.dart';
import '../../../multijugador/sala_bloc.dart';
import '../../../multijugador/sala_event.dart';
import '../../tema.dart';
import '../../widgets/celda_widget.dart';
import '../../widgets/dado_widget.dart';
import '../../widgets/explicacion_de_jugada.dart';
import '../../widgets/tablero_widget.dart';
import 'confirmar_salida.dart';
import 'marcador.dart';
import 'panel_de_zonas.dart';
import 'textos_multijugador.dart';

/// La partida en línea: **mi** tablero, los dos dados de la ronda (iguales para todos), la
/// cuenta regresiva, los puntos de cada jugador y el panel de zonas.
///
/// El servidor dice dónde se puede anotar con cada dado ancla; aquí solo se ilumina eso.
/// Para explicar por qué no se puede en otra casilla, y para apagar un poco las que la
/// regla de su zona bloquea, se usan las reglas de la app, que son las mismas del servidor
/// (una prueba de cada lado lo exige). Nadie ve el tablero de otro jugador.
class VistaPartidaEnLinea extends StatefulWidget {
  final VistaDeSala sala;

  const VistaPartidaEnLinea({super.key, required this.sala});

  @override
  State<VistaPartidaEnLinea> createState() => _VistaPartidaEnLineaState();
}

class _VistaPartidaEnLineaState extends State<VistaPartidaEnLinea>
    with ExplicacionPasajera {
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

  @override
  void didUpdateWidget(VistaPartidaEnLinea anterior) {
    super.didUpdateWidget(anterior);
    // Con la ronda nueva, la explicación de la anterior ya no aplica.
    if (anterior.sala.ronda != widget.sala.ronda) olvidarExplicacion();
  }

  void _elegirAncla(int numero) {
    olvidarExplicacion();
    setState(() {
      _ancla = numero;
      _rondaDelAncla = _sala.ronda;
    });
  }

  Future<void> _confirmarRendirse() async {
    final bloc = context.read<SalaBloc>();
    // El estado que se veía al tocar: si la partida termina con el diálogo abierto, el
    // "sí" ya no rinde a nadie.
    final desde = _sala.estado;
    if (await confirmarRendirse(context)) bloc.add(Rendirse(desde: desde));
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final sala = _sala;
    final yo = sala.yo;
    final ocupado = context.select((SalaBloc bloc) => bloc.state.ocupado);
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
    final tiempo = context.select(
      (SalaBloc bloc) => bloc.state.segundosQueQuedan,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RondaYTiempo(ronda: sala.ronda, segundos: tiempo?.ceil()),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final (indice, valor) in dados.indexed) ...[
              if (indice > 0) const SizedBox(width: 16),
              // Un dado sin jugadas se ve apagado: tocarlo no hace nada. Siempre dentro
              // del mismo Opacity, para que el dado no pierda su salto al cambiar.
              Opacity(
                opacity: puedeJugar && !_opciones.any((o) => o.ancla == valor)
                    ? 0.45
                    : 1,
                child: DadoWidget(
                  key: ValueKey('dado-$indice'),
                  valor: valor,
                  // Con cada ronda, los dados saltan; el segundo, un poquito después.
                  tirada: sala.ronda,
                  saltaAlAparecer: true,
                  demora: indice == 0
                      ? Duration.zero
                      : Cartoon.desfaseDelSegundoDado,
                  anclado: jugada != null && jugada.ancla == valor,
                  alTocar: puedeJugar && _opciones.any((o) => o.ancla == valor)
                      ? () => _elegirAncla(valor)
                      : null,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        LineaDeIndicacion(
          indicacion: _indicacion(yo, jugada, puedeJugar),
          explicacion: explicacion,
          estilo: textos.bodyMedium,
        ),
        const SizedBox(height: 12),
        TableroWidget(
          tablero: tablero,
          // Con un ancla elegida, se puede tocar cualquier casilla vacía: las legales
          // anotan; las demás explican por qué no. Mientras va un pedido, ninguna: así
          // un doble toque no manda dos jugadas.
          esTocable: (posicion) =>
              puedeJugar &&
              !ocupado &&
              jugada != null &&
              tablero.celdaEn(posicion)!.estaVacia,
          iluminacionDe: (posicion) {
            if (legales.contains(posicion.notacion)) return Iluminacion.posible;
            if (!puedeJugar || jugada == null) return Iluminacion.normal;
            final resultado = evaluarJugada(
              tablero,
              posicion,
              ancla: jugada.ancla,
              valor: jugada.valor,
            );
            return resultado is ReglaRota
                ? Iluminacion.bloqueada
                : Iluminacion.normal;
          },
          numeroResaltadoEn: (posicion) =>
              jugada != null &&
              tablero.celdaEn(posicion)?.valor == jugada.ancla,
          marcada: explicada,
          alTocar: (posicion) {
            final elegida = jugada;
            if (elegida == null) return;
            if (legales.contains(posicion.notacion)) {
              borrarExplicacion();
              context.read<SalaBloc>().add(
                JugadaEnviada(
                  ronda: sala.ronda,
                  dadoAncla: elegida.ancla,
                  casilla: posicion.notacion,
                ),
              );
              return;
            }
            // El servidor dice que ahí no: se explica por qué con las reglas de la app.
            final porQue = explicarJugada(
              evaluarJugada(
                tablero,
                posicion,
                ancla: elegida.ancla,
                valor: elegida.valor,
              ),
              valor: elegida.valor,
            );
            if (porQue != null) explicar(porQue, posicion);
          },
        ),
        if (yo.puedePasar && yo.activo && yo.accion == 'pendiente')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton(
              key: const ValueKey('boton-pasar'),
              onPressed: ocupado
                  ? null
                  : () => context.read<SalaBloc>().add(RondaPasada(ronda: sala.ronda)),
              child: const Text('Pasar turno'),
            ),
          ),
        const SizedBox(height: 20),
        Marcador(
          jugadores: sala.jugadores,
          yo: yo.usuario,
          zonas: sala.zonas,
          meta: sala.meta,
          mapa: mapa,
        ),
        const SizedBox(height: 14),
        PanelDeZonas(zonas: sala.zonas),
        const SizedBox(height: 12),
        if (yo.activo)
          TextButton(
            key: const ValueKey('boton-rendirse'),
            style: TextButton.styleFrom(foregroundColor: Paleta.peligro),
            // Mientras va un pedido no se puede: así no se manda dos veces.
            onPressed: ocupado ? null : _confirmarRendirse,
            child: const Text('Rendirme'),
          )
        else
          // Quien quedó fuera sale sin más (la flecha también).
          TextButton(
            key: const ValueKey('boton-salir-de-la-partida'),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Salir'),
          ),
      ],
    );
  }

  String _indicacion(MiVista yo, JugadaLegal? jugada, bool puedeJugar) {
    if (!yo.activo) return textoDeFuera(yo);
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

/// "Ronda 4" y, al lado, una ficha con los segundos que le quedan; en los últimos 10 se
/// pone roja.
class _RondaYTiempo extends StatelessWidget {
  final int ronda;
  final int? segundos;

  const _RondaYTiempo({required this.ronda, required this.segundos});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final segundos = this.segundos;
    final apurado = segundos != null && segundos <= 10;

    return Row(
      key: const ValueKey('ronda-y-tiempo'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // En un celular angosto, el número de ronda se achica antes que desbordarse.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Ronda $ronda',
              key: const ValueKey('numero-de-ronda'),
              style: textos.titleLarge,
            ),
          ),
        ),
        if (segundos != null) ...[
          const SizedBox(width: 12),
          // En los últimos 10 s, la ficha tiembla un instante con cada segundo.
          Sacudida(
            disparador: segundos,
            activa: apurado,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: apurado ? Paleta.peligro : Paleta.cartonClaro,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Paleta.tinta, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: apurado ? Paleta.carton : Paleta.tinta,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$segundos s',
                    key: const ValueKey('tiempo-de-la-ronda'),
                    style: textos.titleSmall?.copyWith(
                      color: apurado ? Paleta.carton : Paleta.tinta,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
