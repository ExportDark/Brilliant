import '../modelo/extraer_valores.dart';
import '../modelo/posicion.dart';
import '../modelo/region.dart';
import '../modelo/tablero.dart';

/// Lo que pasaría si se anotara un número en una casilla del tablero.
sealed class ResultadoJugada {
  const ResultadoJugada();
}

/// La casilla está libre, pegada a un ancla, y la regla de su zona acepta el
/// número.
class JugadaValida extends ResultadoJugada {
  const JugadaValida();
}

/// La casilla ya tiene un número, como las 6 casillas iniciales.
class CasillaOcupada extends ResultadoJugada {
  const CasillaOcupada();
}

/// La casilla está libre, pero ninguna de sus vecinas (arriba, abajo,
/// izquierda o derecha) tiene el número [ancla].
class SinAncla extends ResultadoJugada {
  final int ancla;

  const SinAncla(this.ancla);
}

/// La casilla está libre y pegada a un ancla, pero el número rompería la
/// regla de su zona.
class ReglaRota extends ResultadoJugada {
  /// La zona cuya regla no lo permite.
  final Region region;

  /// Lo que la zona ya tiene anotado, para poder explicar el rechazo.
  final List<int> valoresEnZona;

  const ReglaRota(this.region, this.valoresEnZona);
}

/// Decide si [valor] se puede anotar en [posicion] usando [ancla] como
/// referencia: la casilla tiene que estar libre, pegada (sin diagonales) a
/// una casilla que tenga el número [ancla], y la regla de su zona tiene que
/// aceptar [valor].
///
/// Lanza [ArgumentError] si [posicion] no es una casilla del tablero.
ResultadoJugada evaluarJugada(
  Tablero tablero,
  Posicion posicion, {
  required int ancla,
  required int valor,
}) {
  final celda = tablero.celdaEn(posicion);
  final region = tablero.regionEn(posicion);
  if (celda == null || region == null) {
    throw ArgumentError.value(posicion, 'posicion', 'no es una casilla del tablero');
  }

  if (!celda.estaVacia) return const CasillaOcupada();

  final pegadaAlAncla = posicion.vecinas.any(
    (vecina) => tablero.celdaEn(vecina)?.valor == ancla,
  );
  if (!pegadaAlAncla) return SinAncla(ancla);

  final valores = extraerValores(region);
  if (region.tipo.regla.puedeAgregar(valores, valor)) return const JugadaValida();
  return ReglaRota(region, valores);
}

/// Verdadero si alguna casilla del tablero acepta [valor] pegada a un [ancla].
bool hayJugada(Tablero tablero, {required int ancla, required int valor}) {
  return tablero.celdas.any(
    (celda) =>
        evaluarJugada(tablero, celda.posicion, ancla: ancla, valor: valor) is JugadaValida,
  );
}
