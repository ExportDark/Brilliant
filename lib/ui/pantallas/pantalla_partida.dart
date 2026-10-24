import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../juego/partida_bloc.dart';
import '../../juego/partida_event.dart';
import '../../juego/partida_state.dart';
import '../../juego/validacion_jugada.dart';
import '../../modelo/color_zona.dart';
import '../../modelo/mapa.dart';
import '../../modelo/posicion.dart';
import '../../modelo/tablero.dart';
import '../tema.dart';
import '../widgets/celda_widget.dart';
import '../widgets/dado_widget.dart';
import '../widgets/tablero_widget.dart';
import 'pantalla_preparacion.dart';

/// La pantalla donde se juega la partida, turno por turno.
///
/// Se tiran los dos dados y se toca uno para hacerlo el ancla. El ancla es
/// solo un dado: su número es el que se busca en el tablero, y el otro dado
/// se anota pegado (arriba, abajo, izquierda o derecha) a una casilla que
/// tenga ese número. Esas casillas iluminan su número, y el tablero ilumina
/// las vecinas donde el otro dado cabe, y apenas las que su zona no lo
/// acepta. Tocar una iluminada anota el número; tocar cualquier otra casilla
/// vacía explica, debajo del tablero, por qué no se puede. Si no hay jugada
/// con ningún dado como ancla, se pasa el turno. Al terminar, una tarjeta
/// dice en cuántos turnos se jugó y ofrece jugar otra vez el mismo [mapa].
///
/// Salir a mitad de partida (con la flecha de atrás) pide confirmación, para
/// no perder lo jugado con un toque sin querer.
class PantallaPartida extends StatelessWidget {
  final Tablero tablero;

  /// El mapa de [tablero]: se vuelve a preparar al jugar otra vez.
  final Mapa mapa;

  /// Decide qué sale en cada dado. Sin él salen al azar; los tests lo fijan.
  final int Function()? tirarDado;

  const PantallaPartida({
    super.key,
    required this.tablero,
    this.mapa = nivel1,
    this.tirarDado,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PartidaBloc(tablero, tirarDado: tirarDado),
      child: _VistaPartida(mapa: mapa, tirarDado: tirarDado),
    );
  }
}

class _VistaPartida extends StatefulWidget {
  final Mapa mapa;

  /// Se le pasa a la preparación de la partida siguiente, al jugar otra vez.
  final int Function()? tirarDado;

  const _VistaPartida({required this.mapa, required this.tirarDado});

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
      case SinVecinoConNumero(:final numero):
        setState(() => _explicacion = _explicarVecino(posicion, numero, state.valorAColocar!));
      case CasillaOcupada():
      case null:
        break;
    }
  }

  String _explicarRegla(Posicion posicion, ReglaRota rota) {
    final tipo = rota.region.tipo;
    // Una zona naranja rechaza números de fuera de su rango aunque esté vacía:
    // ahí no hay nada que decir de lo que ya tiene.
    final yaTiene = rota.valoresEnZona.isEmpty
        ? ''
        : ' Ya tiene: ${rota.valoresEnZona.join(', ')}';
    return 'Zona ${_nombreZona(tipo.color)} — ${tipo.regla.descripcion}.$yaTiene';
  }

  String _explicarVecino(Posicion posicion, int numero, int valor) {
    return 'Esa casilla no está junto a ningún$_espacioFijo$numero: el $valor va arriba, '
        'abajo o a un lado de un$_espacioFijo$numero.';
  }

  Iluminacion _iluminacion(PartidaState state, Posicion posicion) {
    return switch (state.evaluar(posicion)) {
      JugadaValida() => Iluminacion.posible,
      ReglaRota() => Iluminacion.bloqueada,
      SinVecinoConNumero() || CasillaOcupada() || null => Iluminacion.normal,
    };
  }

  String _indicacion(PartidaState state) {
    if (state.dados == null) return 'Tira los dados.';
    if (state.sinJugada) return 'Ningún dado tiene jugada. Pasa el turno.';

    final buscado = state.valorAncla;
    final valor = state.valorAColocar;
    if (buscado == null || valor == null) {
      return 'Toca un dado para usarlo de ancla: el otro va junto a una casilla con ese número.';
    }
    return 'Pon el $valor en una casilla iluminada, junto a un$_espacioFijo$buscado.';
  }

  /// Pregunta si de verdad quiere dejar la partida. Devuelve si dijo que sí.
  Future<bool> _confirmarSalida() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir de la partida?'),
        content: const Text('Se pierde lo que llevas jugado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Seguir jugando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    return salir ?? false;
  }

  void _jugarOtraVez() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PantallaPreparacion(mapa: widget.mapa, tirarDado: widget.tirarDado),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartidaBloc, PartidaState>(
      builder: (context, state) {
        final dados = state.dados;
        final explicacion = _explicacion;
        final textos = Theme.of(context).textTheme;

        return PopScope(
          // A mitad de partida, salir pide confirmación; ya terminada, no.
          canPop: state.terminada,
          onPopInvokedWithResult: (salio, _) async {
            if (salio) return;
            final navegador = Navigator.of(context);
            if (await _confirmarSalida()) navegador.pop();
          },
          child: Scaffold(
            appBar: AppBar(title: Text(widget.mapa.nombre)),
            body: SafeArea(
              // Arriba y no centrado en vertical: así el tablero no se mueve
              // cuando aparecen los dados o la explicación.
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Encabezado(
                          titulo: state.terminada ? 'Partida terminada' : 'Turno ${state.turno}',
                          casillasLlenas: state.casillasLlenas,
                        ),
                        if (!state.terminada) ...[
                          const SizedBox(height: 10),
                          Text(
                            _indicacion(state),
                            textAlign: TextAlign.center,
                            style: textos.bodyLarge?.copyWith(color: Paleta.tintaSuave),
                          ),
                        ],
                        const SizedBox(height: 14),
                        TableroWidget(
                          tablero: state.tablero,
                          iluminacionDe: (posicion) => _iluminacion(state, posicion),
                          numeroResaltadoEn: state.tieneNumeroBuscado,
                          esTocable: (posicion) =>
                              state.valorAncla != null &&
                              state.tablero.celdaEn(posicion)!.estaVacia,
                          alTocar: (posicion) => _tocarCasilla(state, posicion),
                        ),
                        if (explicacion != null) ...[
                          const SizedBox(height: 12),
                          _Explicacion(explicacion),
                        ],
                        if (state.terminada) ...[
                          const SizedBox(height: 20),
                          _FinDePartida(
                            tableroLleno: state.casillasLlenas == Tablero.filas * Tablero.columnas,
                            turnos: state.turno - 1,
                            alJugarOtraVez: _jugarOtraVez,
                          ),
                        ] else ...[
                          if (dados != null) ...[
                            const SizedBox(height: 18),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 20,
                              children: [
                                for (final (indice, valor) in dados.indexed)
                                  DadoWidget(
                                    key: ValueKey('dado-$indice'),
                                    valor: valor,
                                    anclado: indice == state.dadoElegido,
                                    alTocar: () => _enviar(DadoElegido(indice)),
                                  ),
                              ],
                            ),
                          ],
                          // Con los dados en la mesa no hace falta ningún botón,
                          // salvo para pasar el turno cuando no hay jugada.
                          if (state.sinJugada) ...[
                            const SizedBox(height: 20),
                            FilledButton.tonal(
                              onPressed: () => _enviar(const TurnoPasado()),
                              style: FilledButton.styleFrom(minimumSize: const Size(220, 56)),
                              child: const _TextoConIcono(Icons.skip_next_rounded, 'Pasar turno'),
                            ),
                          ] else if (dados == null) ...[
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: () => _enviar(const DadosTirados()),
                              style: FilledButton.styleFrom(minimumSize: const Size(220, 56)),
                              child: const _TextoConIcono(Icons.casino_rounded, 'Tirar dados'),
                            ),
                          ],
                        ],
                      ],
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
}

/// El turno en curso (o que la partida terminó) y cuántas casillas van llenas,
/// con una barra de progreso fina.
class _Encabezado extends StatelessWidget {
  final String titulo;
  final int casillasLlenas;

  const _Encabezado({required this.titulo, required this.casillasLlenas});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    const total = Tablero.filas * Tablero.columnas;

    return Column(
      children: [
        Text(
          titulo,
          style: textos.headlineSmall?.copyWith(color: Paleta.tinta, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              key: const ValueKey('progreso'),
              value: casillasLlenas / total,
              minHeight: 6,
              backgroundColor: Paleta.baseTablero,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$casillasLlenas de $total casillas',
          style: textos.bodySmall?.copyWith(color: Paleta.tintaSuave),
        ),
      ],
    );
  }
}

/// La tarjeta del final: cómo terminó la partida y el botón para empezar otra.
class _FinDePartida extends StatelessWidget {
  final bool tableroLleno;
  final int turnos;
  final VoidCallback alJugarOtraVez;

  const _FinDePartida({
    required this.tableroLleno,
    required this.turnos,
    required this.alJugarOtraVez,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Container(
      key: const ValueKey('fin-de-partida'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, size: 44, color: Color(0xFFE0A93B)),
          const SizedBox(height: 8),
          Text(
            tableroLleno ? '¡Tablero completo!' : 'Fin de la partida',
            style: textos.titleLarge?.copyWith(color: Paleta.tinta, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Lo jugaste en $turnos turnos.',
            style: textos.bodyLarge?.copyWith(color: Paleta.tintaSuave),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: alJugarOtraVez,
            child: const _TextoConIcono(Icons.replay_rounded, 'Jugar otra vez'),
          ),
        ],
      ),
    );
  }
}

/// El contenido de un botón: un ícono y su texto.
class _TextoConIcono extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _TextoConIcono(this.icono, this.texto);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icono), const SizedBox(width: 8), Text(texto)],
    );
  }
}

/// Un espacio que no se corta: así un número nunca queda solo en la línea
/// de abajo ("junto a un" / "4.").
const _espacioFijo = '\u00A0';

String _nombreZona(ColorZona color) {
  return switch (color) {
    ColorZona.amarillo => 'amarilla',
    ColorZona.verde => 'verde',
    ColorZona.morado => 'morada',
    ColorZona.azul => 'azul',
    ColorZona.rojo => 'roja',
    ColorZona.gris => 'gris',
    ColorZona.naranja => 'naranja',
  };
}

/// El recuadro suave que explica por qué la casilla tocada no acepta el
/// número.
class _Explicacion extends StatelessWidget {
  final String texto;

  const _Explicacion(this.texto);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: const ValueKey('explicacion'),
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Paleta.aviso,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Paleta.avisoTinta),
            const SizedBox(width: 10),
            Expanded(
              child: Text(texto, style: const TextStyle(color: Paleta.avisoTinta, height: 1.3)),
            ),
          ],
        ),
      ),
    );
  }
}
