import 'dart:async';

import 'package:flutter/material.dart';

import '../../juego/validacion_jugada.dart';
import '../../modelo/color_zona.dart';
import '../../modelo/posicion.dart';
import '../tema.dart';

/// Un espacio que no se corta: así un número nunca queda solo en la línea de abajo
/// ("junto a un" / "4.").
const espacioFijo = ' ';

/// El nombre de una zona en una frase: "la zona morada".
String nombreDeZona(ColorZona color) {
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

/// Por qué no se puede anotar en una casilla: el texto y, si es por la regla de una zona,
/// su color.
class Explicacion {
  final String texto;
  final ColorZona? color;

  const Explicacion(this.texto, [this.color]);
}

/// La explicación de por qué [valor] no se puede anotar, según [resultado], o `null` si
/// no hay nada que explicar (la jugada vale, o la casilla ya tiene número).
///
/// La usan la partida de un jugador y la partida en línea, con las mismas reglas.
Explicacion? explicarJugada(ResultadoJugada resultado, {required int valor}) {
  return switch (resultado) {
    ReglaRota(:final region, :final valoresEnZona) => Explicacion(
        // Una zona naranja rechaza números de fuera de su rango aunque esté vacía: ahí no
        // hay nada que decir de lo que ya tiene.
        'Zona ${nombreDeZona(region.tipo.color)} — ${region.tipo.regla.descripcion}.'
        '${valoresEnZona.isEmpty ? '' : ' Ya tiene: ${valoresEnZona.join(', ')}'}',
        region.tipo.color,
      ),
    SinVecinoConNumero(:final numero) => Explicacion(
        'Esa casilla no está junto a ningún$espacioFijo$numero: el $valor va arriba, abajo o '
        'a un lado de un$espacioFijo$numero.',
      ),
    JugadaValida() || CasillaOcupada() => null,
  };
}

/// La línea de arriba del tablero: qué hay que hacer, o, por unos segundos, por qué no se
/// pudo anotar donde se tocó. Sin recuadro, para que no tape ni mueva nada: un punto del
/// color de la zona y el texto, que aparece y se va con un fundido.
class LineaDeIndicacion extends StatelessWidget {
  final String indicacion;
  final Explicacion? explicacion;
  final TextStyle? estilo;

  /// La clave del texto de la indicación (los tests la buscan).
  final Key claveDeIndicacion;

  const LineaDeIndicacion({
    super.key,
    required this.indicacion,
    this.explicacion,
    this.estilo,
    this.claveDeIndicacion = const ValueKey('indicacion'),
  });

  @override
  Widget build(BuildContext context) {
    final base = estilo ?? Theme.of(context).textTheme.bodyMedium;
    final explicacion = this.explicacion;
    final color = explicacion?.color;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: explicacion == null
          ? Text(
              indicacion,
              key: claveDeIndicacion,
              textAlign: TextAlign.center,
              style: base?.copyWith(color: Paleta.tintaSuave),
            )
          : Row(
              key: const ValueKey('explicacion'),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (color != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: coloresDeZona[color],
                      shape: BoxShape.circle,
                      border: Border.all(color: Paleta.tinta.withValues(alpha: 0.25)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    explicacion.texto,
                    textAlign: TextAlign.center,
                    style: base?.copyWith(color: Paleta.tinta),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Lo que comparten las dos partidas para explicar una casilla: la explicación y la
/// casilla que se tocó, que se borran solas a los [duracion] segundos o con lo siguiente
/// que haga el jugador.
mixin ExplicacionPasajera<T extends StatefulWidget> on State<T> {
  static const duracion = Duration(seconds: 4);

  Explicacion? explicacion;

  /// La casilla que se tocó y no se pudo usar: lleva un aro suave mientras dura la
  /// explicación.
  Posicion? explicada;

  Timer? _borrado;

  void explicar(Explicacion nueva, Posicion casilla) {
    _borrado?.cancel();
    setState(() {
      explicacion = nueva;
      explicada = casilla;
    });
    _borrado = Timer(duracion, borrarExplicacion);
  }

  void borrarExplicacion() {
    _borrado?.cancel();
    if (!mounted || (explicacion == null && explicada == null)) return;
    setState(olvidarExplicacion);
  }

  /// Borra la explicación sin redibujar: para cuando ya se va a redibujar igual.
  void olvidarExplicacion() {
    _borrado?.cancel();
    explicacion = null;
    explicada = null;
  }

  @override
  void dispose() {
    _borrado?.cancel();
    super.dispose();
  }
}
