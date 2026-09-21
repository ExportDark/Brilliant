import 'celda.dart';
import 'posicion.dart';
import 'tipo_region.dart';

/// Una región física del tablero: un grupo concreto de celdas que comparte
/// un [TipoRegion] (color + regla + cantidad de celdas esperada).
class Region {
  final int identificador;
  final TipoRegion tipo;
  final List<Celda> casillas;

  Region({
    required this.identificador,
    required this.tipo,
    required this.casillas,
  }) : assert(
         casillas.length == tipo.cantidadCeldas,
         'La región #$identificador (${tipo.color}) debería tener '
         '${tipo.cantidadCeldas} celdas, pero tiene ${casillas.length}.',
       );

  /// Verdadero cuando todas las casillas de la región ya tienen un valor.
  /// Calculado siempre a partir de [casillas], nunca guardado aparte.
  bool get completada => casillas.every((celda) => !celda.estaVacia);

  /// Devuelve una región nueva con [valor] anotado en [posicion], dejando el
  /// resto de las casillas intactas.
  Region conCasilla(Posicion posicion, int valor) {
    return Region(
      identificador: identificador,
      tipo: tipo,
      casillas: [
        for (final casilla in casillas)
          casilla.posicion == posicion ? casilla.conValor(valor) : casilla,
      ],
    );
  }

  /// Devuelve una región nueva con la casilla de [posicion] vaciada.
  Region sinCasilla(Posicion posicion) {
    return Region(
      identificador: identificador,
      tipo: tipo,
      casillas: [
        for (final casilla in casillas)
          casilla.posicion == posicion ? casilla.sinValor() : casilla,
      ],
    );
  }
}
