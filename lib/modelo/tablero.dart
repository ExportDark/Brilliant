import 'celda.dart';
import 'posicion.dart';
import 'region.dart';
import 'tipo_region.dart';

/// Las 6 casillas que se llenan en la preparación, antes de tirar los dados,
/// con los números del 1 al 6 sin repetir.
const casillasIniciales = {'C1', 'F2', 'B4', 'E4', 'C6', 'E7'};

/// El tablero del juego: la grilla completa, dividida en regiones de color.
///
/// Cada región se declara con la lista de casillas que la forman, en la
/// notación del manual — así el layout se lee igual que en el documento y no
/// hay que deducir por adyacencia a cuál de las dos regiones de un mismo
/// color pertenece cada casilla.
class Tablero {
  static const filas = 7;
  static const columnas = 7;

  final List<Region> regiones;
  final Map<Posicion, Region> _regionPorPosicion;

  Tablero._(this.regiones, this._regionPorPosicion);

  /// El mapa original de 7x7 documentado en el manual.
  factory Tablero.mapaOriginal() {
    final regiones = [
      _construirRegion(1, tipoAmarillo, ['A1', 'G1', 'D4', 'A7', 'G7']),
      _construirRegion(2, tipoVerde, ['B1', 'A2', 'B2', 'A3', 'A4', 'A5']),
      _construirRegion(3, tipoVerde, ['G2', 'G3', 'F3', 'E4', 'F4', 'G4']),
      _construirRegion(4, tipoAzul, ['C1', 'C2', 'D2', 'D3']),
      _construirRegion(5, tipoAzul, ['G5', 'G6', 'F6', 'F7']),
      _construirRegion(6, tipoMorado, ['D1', 'E1', 'F1', 'E2', 'F2', 'E3']),
      _construirRegion(7, tipoMorado, ['C4', 'C5', 'D5', 'C6', 'C7', 'B7']),
      _construirRegion(8, tipoRojo, ['B3', 'C3', 'B4', 'B5', 'B6', 'A6']),
      _construirRegion(9, tipoRojo, ['E5', 'F5', 'E6', 'D6', 'D7', 'E7']),
    ];
    return Tablero._(regiones, _indexarPorPosicion(regiones));
  }

  Iterable<Celda> get celdas => regiones.expand((region) => region.casillas);

  Region? regionEn(Posicion posicion) => _regionPorPosicion[posicion];

  Celda? celdaEn(Posicion posicion) {
    final region = _regionPorPosicion[posicion];
    if (region == null) return null;
    return region.casillas.firstWhere((celda) => celda.posicion == posicion);
  }

  static Region _construirRegion(
    int identificador,
    TipoRegion tipo,
    List<String> notaciones,
  ) {
    final casillas = [
      for (final notacion in notaciones)
        Celda(
          posicion: Posicion.desdeNotacion(notacion),
          color: tipo.color,
          esInicial: casillasIniciales.contains(notacion),
        ),
    ];
    return Region(identificador: identificador, tipo: tipo, casillas: casillas);
  }

  /// Indexa las celdas por posición y, de paso, verifica que el layout
  /// transcrito a mano cubra la grilla exactamente una vez.
  static Map<Posicion, Region> _indexarPorPosicion(List<Region> regiones) {
    final indice = <Posicion, Region>{};

    for (final region in regiones) {
      for (final celda in region.casillas) {
        final previa = indice[celda.posicion];
        if (previa != null) {
          throw StateError(
            'La casilla ${celda.posicion.notacion} está declarada en la región '
            '#${previa.identificador} y también en la #${region.identificador}.',
          );
        }
        indice[celda.posicion] = region;
      }
    }

    for (var fila = 0; fila < filas; fila++) {
      for (var columna = 0; columna < columnas; columna++) {
        final posicion = Posicion(fila: fila, columna: columna);
        if (!indice.containsKey(posicion)) {
          throw StateError('Ninguna región cubre la casilla ${posicion.notacion}.');
        }
      }
    }

    if (indice.length != filas * columnas) {
      throw StateError(
        'Las regiones cubren ${indice.length} casillas, pero el tablero es de '
        '${filas * columnas}: alguna casilla declarada cae fuera de la grilla.',
      );
    }

    return indice;
  }
}
