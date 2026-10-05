import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../juego/preparacion_bloc.dart';
import '../../juego/preparacion_event.dart';
import '../../juego/preparacion_state.dart';
import '../../modelo/posicion.dart';
import '../../modelo/tablero.dart';
import '../widgets/tablero_widget.dart';
import 'pantalla_partida.dart';

/// La pantalla donde el jugador reparte los números del 1 al 6 entre las
/// casillas iniciales, antes de tirar el primer dado.
///
/// Se toca una casilla inicial (en el tablero o en el resumen) y después un
/// número, o "Aleatorio" para que el azar complete lo que falta. El botón
/// "Inicio" solo se habilita con todas las casillas llenas;
/// al oprimirlo se pasa a la [PantallaPartida] con los valores ya fijos.
class PantallaPreparacion extends StatelessWidget {
  const PantallaPreparacion({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PreparacionBloc(
        casillasIniciales.map(Posicion.desdeNotacion).toList(),
      ),
      child: const _VistaPreparacion(),
    );
  }
}

class _VistaPreparacion extends StatefulWidget {
  const _VistaPreparacion();

  @override
  State<_VistaPreparacion> createState() => _VistaPreparacionState();
}

class _VistaPreparacionState extends State<_VistaPreparacion> {
  final _tableroBase = Tablero.mapaOriginal();

  /// La casilla donde va a caer el próximo número. Es estado de la pantalla,
  /// no del reparto: el bloc no necesita saber qué casilla se está mirando.
  Posicion? _seleccionada;

  PreparacionBloc get _bloc => context.read<PreparacionBloc>();

  @override
  void initState() {
    super.initState();
    _seleccionada = _bloc.state.casillas.first;
  }

  void _seleccionar(Posicion casilla) {
    setState(() => _seleccionada = casilla);
  }

  void _asignar(PreparacionState state, int valor) {
    final casilla = _seleccionada;
    if (casilla == null) return;

    _bloc.add(ValorAsignado(casilla, valor));
    setState(() => _seleccionada = _siguienteVacia(state, casilla));
  }

  void _quitar() {
    final casilla = _seleccionada;
    if (casilla == null) return;

    _bloc.add(ValorQuitado(casilla));
  }

  void _reiniciar(PreparacionState state) {
    _bloc.add(const PreparacionReiniciada());
    setState(() => _seleccionada = state.casillas.first);
  }

  /// La siguiente casilla vacía después de [actual], dando la vuelta a la
  /// lista, o `null` si ya no queda ninguna.
  Posicion? _siguienteVacia(PreparacionState state, Posicion actual) {
    final casillas = state.casillas;
    final inicio = casillas.indexOf(actual);
    for (var salto = 1; salto < casillas.length; salto++) {
      final candidata = casillas[(inicio + salto) % casillas.length];
      if (state.valorDe(candidata) == null) return candidata;
    }
    return null;
  }

  /// Un número se puede elegir si nadie lo usa todavía, o si es el que ya
  /// tiene la casilla seleccionada.
  bool _puedeElegir(PreparacionState state, int valor) {
    final casilla = _seleccionada;
    if (casilla == null) return false;
    return state.disponibles.contains(valor) || state.valorDe(casilla) == valor;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PreparacionBloc, PreparacionState>(
      listenWhen: (antes, ahora) => !antes.confirmada && ahora.confirmada,
      listener: (context, state) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PantallaPartida(tablero: _tableroBase.conValores(state.valores)),
          ),
        );
      },
      builder: (context, state) {
        final seleccionada = _seleccionada;
        final faltan = state.casillas.length - state.valores.length;

        return Scaffold(
          appBar: AppBar(title: const Text('Brilliant — preparación')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.completa
                        ? 'Listo: oprime Inicio para empezar la partida.'
                        : 'Toca una casilla inicial y elige su número. Faltan $faltan.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TableroWidget(
                    tablero: _tableroBase.conValores(state.valores),
                    seleccionada: seleccionada,
                    esTocable: state.casillas.contains,
                    alTocar: _seleccionar,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final casilla in state.casillas)
                        ChoiceChip(
                          key: ValueKey('resumen-${casilla.notacion}'),
                          label: Text('${casilla.notacion} = ${state.valorDe(casilla) ?? '—'}'),
                          selected: casilla == seleccionada,
                          onSelected: (_) => _seleccionar(casilla),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final valor in valoresPosibles)
                        FilledButton.tonal(
                          key: ValueKey('numero-$valor'),
                          onPressed: _puedeElegir(state, valor)
                              ? () => _asignar(state, valor)
                              : null,
                          child: Text('$valor', style: const TextStyle(fontSize: 18)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: seleccionada != null && state.valorDe(seleccionada) != null
                            ? _quitar
                            : null,
                        child: const Text('Quitar'),
                      ),
                      OutlinedButton(
                        onPressed: state.valores.isNotEmpty ? () => _reiniciar(state) : null,
                        child: const Text('Reiniciar'),
                      ),
                      OutlinedButton(
                        onPressed: () => _bloc.add(const RepartoAleatorio()),
                        child: const Text('Aleatorio'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    // Sin todas las casillas llenas no se puede empezar. El bloc
                    // tampoco confirmaría, pero así el jugador lo ve de entrada.
                    onPressed: state.completa
                        ? () => _bloc.add(const PreparacionConfirmada())
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                    ),
                    child: const Text('Inicio', style: TextStyle(fontSize: 20)),
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
