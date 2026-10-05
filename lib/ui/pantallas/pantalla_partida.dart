import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../juego/partida_bloc.dart';
import '../../juego/partida_event.dart';
import '../../juego/partida_state.dart';
import '../../juego/validacion_jugada.dart';
import '../../modelo/color5.dart';
import '../../modelo/posicion.dart';
import '../../modelo/tablero.dart';
import '../widgets/celda_widget.dart';
import '../widgets/tablero_widget.dart';

/// La pantalla donde se juega la partida, turno por turno.
///
/// Se tiran los dos dados y se toca uno para hacerlo el ancla: el otro se
/// anota pegado (arriba, abajo, izquierda o derecha) a una casilla que tenga
/// el número del ancla. Esas casillas llevan la marca de ancla, y el tablero
/// ilumina las vecinas donde el número cabe, y apenas las que su zona no lo
/// acepta. Tocar una iluminada anota el número; tocar cualquier otra casilla
/// vacía explica, debajo del tablero, por qué no se puede. Si no hay jugada
/// con ningún dado como ancla, se pasa el turno.
class PantallaPartida extends StatelessWidget {
  final Tablero tablero;

  /// Decide qué sale en cada dado. Sin él salen al azar; los tests lo fijan.
  final int Function()? tirarDado;

  const PantallaPartida({super.key, required this.tablero, this.tirarDado});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PartidaBloc(tablero, tirarDado: tirarDado),
      child: const _VistaPartida(),
    );
  }
}

class _VistaPartida extends StatefulWidget {
  const _VistaPartida();

  @override
  State<_VistaPartida> createState() => _VistaPartidaState();
}

class _VistaPartidaState extends State<_VistaPartida> {
  /// Por qué no se puede anotar en la última casilla vacía que se tocó sin
  /// jugada. Es estado de la pantalla: al bloc no le importa qué se mira.
  String? _explicacion;

  PartidaBloc get _bloc => context.read<PartidaBloc>();

  /// Manda [event] y borra la explicación, que ya no aplica a lo que sigue.
  void _enviar(PartidaEvent event) {
    setState(() => _explicacion = null);
    _bloc.add(event);
  }

  void _tocarCasilla(PartidaState state, Posicion posicion) {
    switch (state.evaluar(posicion)) {
      case JugadaValida():
        _enviar(ValorColocado(posicion));
      case final ReglaRota rota:
        setState(() => _explicacion = _explicarRegla(posicion, rota));
      case SinAncla(:final ancla):
        setState(() => _explicacion = _explicarAncla(posicion, ancla, state.valorAColocar!));
      case CasillaOcupada():
      case null:
        break;
    }
  }

  String _explicarRegla(Posicion posicion, ReglaRota rota) {
    final tipo = rota.region.tipo;
    return '${posicion.notacion} · Zona ${_nombreZona(tipo.color)} — '
        '${tipo.regla.descripcion}. Ya tiene: ${rota.valoresEnZona.join(', ')}';
  }

  String _explicarAncla(Posicion posicion, int ancla, int valor) {
    return '${posicion.notacion} no está junto a ningún $ancla: el $valor va arriba, '
        'abajo, a la izquierda o a la derecha de un $ancla.';
  }

  Iluminacion _iluminacion(PartidaState state, Posicion posicion) {
    return switch (state.evaluar(posicion)) {
      JugadaValida() => Iluminacion.posible,
      ReglaRota() => Iluminacion.bloqueada,
      SinAncla() || CasillaOcupada() || null => Iluminacion.normal,
    };
  }

  String _indicacion(PartidaState state) {
    if (state.terminada) {
      return 'Fin de la partida: llenaste ${state.casillasLlenas} de '
          '${Tablero.filas * Tablero.columnas} casillas.';
    }
    if (state.dados == null) return 'Tira los dados.';
    if (state.sinJugada) return 'No hay jugada con ningún dado como ancla: pasa el turno.';

    final ancla = state.valorAncla;
    final valor = state.valorAColocar;
    if (ancla == null || valor == null) {
      return 'Elige el dado ancla: el otro se pone junto a una casilla con ese número.';
    }
    return 'Pon el $valor junto a un $ancla (arriba, abajo, izquierda o derecha).';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartidaBloc, PartidaState>(
      builder: (context, state) {
        final dados = state.dados;
        final explicacion = _explicacion;
        final textos = Theme.of(context).textTheme;

        return Scaffold(
          appBar: AppBar(title: const Text('Brilliant — partida')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Turno ${state.turno}', style: textos.titleLarge),
                  const SizedBox(height: 4),
                  Text(_indicacion(state), style: textos.titleMedium),
                  const SizedBox(height: 16),
                  TableroWidget(
                    tablero: state.tablero,
                    iluminacionDe: (posicion) => _iluminacion(state, posicion),
                    esAncla: state.esAncla,
                    esTocable: (posicion) =>
                        state.valorAncla != null &&
                        state.tablero.celdaEn(posicion)!.estaVacia,
                    alTocar: (posicion) => _tocarCasilla(state, posicion),
                  ),
                  if (explicacion != null) ...[
                    const SizedBox(height: 16),
                    _Explicacion(explicacion),
                  ],
                  if (dados != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 16,
                      children: [
                        for (final (indice, valor) in dados.indexed)
                          _Dado(
                            key: ValueKey('dado-$indice'),
                            valor: valor,
                            anclado: indice == state.dadoElegido,
                            alTocar: () => _enviar(DadoElegido(indice)),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (state.sinJugada)
                    FilledButton.tonal(
                      onPressed: () => _enviar(const TurnoPasado()),
                      child: const Text('Pasar turno', style: TextStyle(fontSize: 18)),
                    )
                  else
                    FilledButton(
                      onPressed: dados == null && !state.terminada
                          ? () => _enviar(const DadosTirados())
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      ),
                      child: const Text('Tirar dados', style: TextStyle(fontSize: 18)),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _nombreZona(Color5 color) {
  return switch (color) {
    Color5.amarillo => 'amarilla',
    Color5.verde => 'verde',
    Color5.morado => 'morada',
    Color5.azul => 'azul',
    Color5.rojo => 'roja',
  };
}

/// Un dado de la tirada. El que es ancla lleva borde ámbar y un ancla debajo.
class _Dado extends StatelessWidget {
  final int valor;
  final bool anclado;
  final VoidCallback alTocar;

  const _Dado({
    super.key,
    required this.valor,
    required this.anclado,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: anclado ? Colors.amber.shade700 : Colors.black54,
        width: anclado ? 4 : 2,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          selected: anclado,
          child: Material(
            color: anclado ? Colors.amber.shade100 : Colors.white,
            shape: forma,
            child: InkWell(
              customBorder: forma,
              onTap: alTocar,
              child: SizedBox(
                width: 64,
                height: 64,
                child: Center(
                  child: Text(
                    '$valor',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Visibility.maintain(
          visible: anclado,
          child: Icon(Icons.anchor, size: 20, color: Colors.amber.shade800),
        ),
      ],
    );
  }
}

/// El recuadro que explica por qué la casilla tocada no acepta el número.
class _Explicacion extends StatelessWidget {
  final String texto;

  const _Explicacion(this.texto);

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return ConstrainedBox(
      key: const ValueKey('explicacion'),
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colores.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.block, color: colores.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(texto, style: TextStyle(color: colores.onErrorContainer)),
            ),
          ],
        ),
      ),
    );
  }
}
