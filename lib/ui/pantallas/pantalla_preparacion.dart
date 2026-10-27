import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../juego/preparacion_bloc.dart';
import '../../juego/preparacion_event.dart';
import '../../juego/preparacion_state.dart';
import '../../modelo/mapa.dart';
import '../../modelo/posicion.dart';
import '../../modelo/tablero.dart';
import '../tema.dart';
import '../widgets/tablero_widget.dart';
import 'pantalla_partida.dart';

/// La pantalla donde el jugador reparte los números del 1 al 6 entre las
/// casillas iniciales de [mapa], antes de tirar el primer dado.
///
/// Se toca una casilla inicial (las que tienen aro) y después un número, o
/// "Aleatorio" para que el azar complete lo que falta. El botón "Inicio" solo
/// se habilita con todas las casillas llenas; al oprimirlo se pasa a la
/// [PantallaPartida] con los valores ya fijos.
class PantallaPreparacion extends StatelessWidget {
  final Mapa mapa;

  /// Decide qué sale en los dados de la partida que arranca desde aquí. Sin él
  /// salen al azar; los tests lo fijan.
  final int Function()? tirarDado;

  const PantallaPreparacion({super.key, this.mapa = nivel1, this.tirarDado});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PreparacionBloc(
        mapa.casillasIniciales.map(Posicion.desdeNotacion).toList(),
        // En el Nivel 4, las iniciales de las zonas naranjas solo aceptan
        // los números de su rango.
        admite: Tablero.desdeMapa(mapa).aceptaComoInicial,
      ),
      child: _VistaPreparacion(mapa: mapa, tirarDado: tirarDado),
    );
  }
}

class _VistaPreparacion extends StatefulWidget {
  final Mapa mapa;
  final int Function()? tirarDado;

  const _VistaPreparacion({required this.mapa, required this.tirarDado});

  @override
  State<_VistaPreparacion> createState() => _VistaPreparacionState();
}

class _VistaPreparacionState extends State<_VistaPreparacion> {
  late final _tableroBase = Tablero.desdeMapa(widget.mapa);

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

  /// Un número se puede elegir si cabe en la casilla seleccionada (en una
  /// zona naranja, solo los de su rango) y si nadie lo usa todavía, o si es
  /// el que ya tiene esa casilla.
  bool _puedeElegir(PreparacionState state, int valor) {
    final casilla = _seleccionada;
    if (casilla == null) return false;
    if (!_bloc.admite(casilla, valor)) return false;
    return state.disponibles.contains(valor) || state.valorDe(casilla) == valor;
  }

  String _indicacion(PreparacionState state) {
    if (state.completa) return '¡Listo! Toca Inicio para empezar.';
    return 'Toca una casilla con aro y elige su número.';
  }

  /// Cuántos números faltan por repartir, o `null` si ya están todos.
  String? _cuantosFaltan(PreparacionState state) {
    final faltan = state.casillas.length - state.valores.length;
    if (faltan == 0) return null;
    return faltan == 1 ? 'Falta 1' : 'Faltan $faltan';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PreparacionBloc, PreparacionState>(
      listenWhen: (antes, ahora) => !antes.confirmada && ahora.confirmada,
      listener: (context, state) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PantallaPartida(
              tablero: _tableroBase.conValores(state.valores),
              mapa: widget.mapa,
              tirarDado: widget.tirarDado,
            ),
          ),
        );
      },
      builder: (context, state) {
        final seleccionada = _seleccionada;
        final textos = Theme.of(context).textTheme;

        return Scaffold(
          appBar: AppBar(title: Text(widget.mapa.nombre)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Prepara tu tablero',
                        style: textos.headlineSmall?.copyWith(
                          color: Paleta.tinta,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _indicacion(state),
                        textAlign: TextAlign.center,
                        style: textos.bodyLarge?.copyWith(color: Paleta.tintaSuave),
                      ),
                      if (_cuantosFaltan(state) case final cuantos?) ...[
                        const SizedBox(height: 2),
                        Text(
                          cuantos,
                          style: textos.bodyMedium?.copyWith(
                            color: Paleta.acento,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TableroWidget(
                        tablero: _tableroBase.conValores(state.valores),
                        seleccionada: seleccionada,
                        esTocable: state.casillas.contains,
                        alTocar: _seleccionar,
                      ),
                      const SizedBox(height: 20),
                      // Los 6 números siempre en una fila: en un celular angosto
                      // las fichas se achican para caber.
                      LayoutBuilder(
                        builder: (context, restricciones) {
                          const separacion = 10.0;
                          final queCabe =
                              (restricciones.maxWidth - separacion * 5) / valoresPosibles.length;
                          final tamano = queCabe < 52 ? queCabe.floorToDouble() : 52.0;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: separacion,
                            children: [
                              for (final valor in valoresPosibles)
                                _FichaDeNumero(
                                  valor: valor,
                                  tamano: tamano,
                                  alElegir: _puedeElegir(state, valor)
                                      ? () => _asignar(state, valor)
                                      : null,
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          _Accion(
                            icono: Icons.casino_outlined,
                            texto: 'Aleatorio',
                            alTocar: () => _bloc.add(const RepartoAleatorio()),
                          ),
                          _Accion(
                            icono: Icons.backspace_outlined,
                            texto: 'Quitar',
                            alTocar: seleccionada != null && state.valorDe(seleccionada) != null
                                ? _quitar
                                : null,
                          ),
                          _Accion(
                            icono: Icons.refresh_rounded,
                            texto: 'Reiniciar',
                            alTocar: state.valores.isNotEmpty ? () => _reiniciar(state) : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        // Sin todas las casillas llenas no se puede empezar. El bloc
                        // tampoco confirmaría, pero así el jugador lo ve de entrada.
                        onPressed: state.completa
                            ? () => _bloc.add(const PreparacionConfirmada())
                            : null,
                        style: FilledButton.styleFrom(minimumSize: const Size(220, 56)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Inicio'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Uno de los números del 1 al 6 para repartir, como una ficha redonda. Los
/// que ya se usaron se ven apagados y no se pueden tocar.
class _FichaDeNumero extends StatelessWidget {
  final int valor;
  final double tamano;
  final VoidCallback? alElegir;

  const _FichaDeNumero({required this.valor, required this.tamano, required this.alElegir});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      key: ValueKey('numero-$valor'),
      onPressed: alElegir,
      style: FilledButton.styleFrom(
        shape: const CircleBorder(),
        fixedSize: Size.square(tamano),
        minimumSize: Size.square(tamano),
        // Sin el margen de toque extra de 48 px que Flutter agrega por
        // defecto: si no, en un celular angosto las 6 fichas no caben en fila.
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        textStyle: TextStyle(fontSize: tamano * 0.4, fontWeight: FontWeight.w700),
      ),
      child: Text('$valor'),
    );
  }
}

/// Una acción secundaria de la preparación: discreta, con ícono y texto.
class _Accion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback? alTocar;

  const _Accion({required this.icono, required this.texto, required this.alTocar});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: alTocar,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icono, size: 20), const SizedBox(width: 6), Text(texto)],
      ),
    );
  }
}
