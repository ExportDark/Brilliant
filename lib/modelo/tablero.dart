import 'celda.dart';
import 'mapa.dart';
import 'posicion.dart';
import 'region.dart';
import 'tipo_region.dart';

/// El tablero del juego: la grilla completa, dividida en regiones de color.
/// Se arma a partir de uno de los [mapas] oficiales.
class Tablero {
  static const filas = 7;
  static const columnas = 7;

  final List<Region> regiones;
  final Map<Posicion, Region> _regionPorPosicion;

  Tablero._(this.regiones, this._regionPorPosicion);

  /// El tablero vacío de [mapa], con sus casillas iniciales marcadas. Las
  /// regiones se numeran desde 1 en el orden en que el mapa declara sus zonas.
  factory Tablero.desdeMapa(Mapa mapa) {
    final iniciales = mapa.casillasIniciales.toSet();
    final regiones = [
      for (final (indice, zona) in mapa.zonas.indexed)
        _construirRegion(indice + 1, zona.tipo, zona.casillas, iniciales),
    ];
    return Tablero._(regiones, _indexarPorPosicion(regiones));
  }

  /// El mapa del manual de la imitación: el [nivel1].
  factory Tablero.mapaOriginal() => Tablero.desdeMapa(nivel1);

  Iterable<Celda> get celdas => regiones.expand((region) => region.casillas);

  Region? regionEn(Posicion posicion) => _regionPorPosicion[posicion];

  /// Si [valor] cabe en [posicion] al empezar la partida, con su zona todavía
  /// vacía. Es lo que se le pregunta a cada casilla inicial: como cada una
  /// está en una zona distinta, solo una zona naranja ("1-3" o "4-6") puede
  /// rechazar un número.
  bool aceptaComoInicial(Posicion posicion, int valor) {
    return regionEn(posicion)?.tipo.regla.puedeAgregar(const [], valor) ?? false;
  }

  Celda? celdaEn(Posicion posicion) {
    final region = _regionPorPosicion[posicion];
    if (region == null) return null;
    return region.casillas.firstWhere((celda) => celda.posicion == posicion);
  }

  /// Devuelve un tablero nuevo con [valor] anotado en [posicion].
  /// Si la posición no existe en el tablero, devuelve el mismo tablero.
  Tablero conValor(Posicion posicion, int valor) {
    return _reemplazandoRegionEn(
      posicion,
      (region) => region.conCasilla(posicion, valor),
    );
  }

  /// Devuelve un tablero nuevo con cada valor de [valores] anotado en su
  /// posición. Las posiciones que no existen en el tablero se ignoran.
  Tablero conValores(Map<Posicion, int> valores) {
    return valores.entries.fold(
      this,
      (tablero, asignacion) => tablero.conValor(asignacion.key, asignacion.value),
    );
  }

  /// Devuelve un tablero nuevo con la casilla de [posicion] vaciada.
  Tablero sinValor(Posicion posicion) {
    return _reemplazandoRegionEn(
      posicion,
      (region) => region.sinCasilla(posicion),
    );
  }

  Tablero _reemplazandoRegionEn(Posicion posicion, Region Function(Region) actualizar) {
    final region = _regionPorPosicion[posicion];
    if (region == null) return this;

    final nuevasRegiones = [
      for (final actual in regiones)
        actual.identificador == region.identificador ? actualizar(actual) : actual,
    ];
    return Tablero._(nuevasRegiones, _indexarPorPosicion(nuevasRegiones));
  }

  static Region _construirRegion(
    int identificador,
    TipoRegion tipo,
    List<String> notaciones,
    Set<String> iniciales,
  ) {
    final casillas = [
      for (final notacion in notaciones)
        Celda(
          posicion: Posicion.desdeNotacion(notacion),
          color: tipo.color,
          esInicial: iniciales.contains(notacion),
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
