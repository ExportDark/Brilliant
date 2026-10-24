import 'tipo_region.dart';

/// Una zona de un mapa: su tipo y sus casillas, en la notación del manual.
typedef ZonaDelMapa = ({TipoRegion tipo, List<String> casillas});

/// Uno de los mapas oficiales: qué zonas tiene, de qué tipo, y cuáles son sus
/// 6 casillas iniciales. [Tablero.desdeMapa] lo convierte en un tablero.
///
/// Cada zona se declara con la lista de sus casillas, no como una grilla de
/// colores: así se sabe a cuál de las zonas de un mismo color pertenece cada
/// casilla, y el layout se lee igual que en la tarjeta del mapa.
class Mapa {
  final int nivel;

  /// Las 6 casillas que se llenan en la preparación, en el orden en que se
  /// van seleccionando. Cada una cae en una zona distinta, así que ningún
  /// reparto del 1 al 6 rompe una regla desde el arranque.
  final List<String> casillasIniciales;

  final List<ZonaDelMapa> zonas;

  const Mapa({required this.nivel, required this.casillasIniciales, required this.zonas});

  String get nombre => 'Nivel $nivel';
}

/// Los 4 mapas oficiales, en orden.
const mapas = [nivel1, nivel2, nivel3, nivel4];

/// El mapa del manual de la imitación, el "Level 1" de las tarjetas.
const nivel1 = Mapa(
  nivel: 1,
  casillasIniciales: ['C1', 'F2', 'B4', 'E4', 'C6', 'E7'],
  zonas: [
    (tipo: tipoAmarillo, casillas: ['A1', 'G1', 'D4', 'A7', 'G7']),
    (tipo: tipoVerde, casillas: ['B1', 'A2', 'B2', 'A3', 'A4', 'A5']),
    (tipo: tipoVerde, casillas: ['G2', 'G3', 'F3', 'E4', 'F4', 'G4']),
    (tipo: tipoAzul, casillas: ['C1', 'C2', 'D2', 'D3']),
    (tipo: tipoAzul, casillas: ['G5', 'G6', 'F6', 'F7']),
    (tipo: tipoMorado, casillas: ['D1', 'E1', 'F1', 'E2', 'F2', 'E3']),
    (tipo: tipoMorado, casillas: ['C4', 'C5', 'D5', 'C6', 'C7', 'B7']),
    (tipo: tipoRojo, casillas: ['B3', 'C3', 'B4', 'B5', 'B6', 'A6']),
    (tipo: tipoRojo, casillas: ['E5', 'F5', 'E6', 'D6', 'D7', 'E7']),
  ],
);

/// El "Level 2": dos zonas de casi todos los colores, y una gris de solo dos
/// casillas, arriba y abajo al centro.
const nivel2 = Mapa(
  nivel: 2,
  casillasIniciales: ['C1', 'F2', 'B4', 'E4', 'C6', 'E7'],
  zonas: [
    (tipo: tipoAmarillo, casillas: ['B2', 'F2', 'D4', 'B6', 'F6']),
    (tipo: tipoVerde, casillas: ['E1', 'F1', 'G1', 'G2', 'G3']),
    (tipo: tipoVerde, casillas: ['A5', 'A6', 'A7', 'B7', 'C7']),
    (tipo: tipoAzul, casillas: ['C2', 'D2', 'E2', 'D3', 'E3']),
    (tipo: tipoAzul, casillas: ['C5', 'D5', 'C6', 'D6', 'E6']),
    (tipo: tipoMorado, casillas: ['A1', 'B1', 'C1', 'A2', 'A3']),
    (tipo: tipoMorado, casillas: ['G5', 'G6', 'E7', 'F7', 'G7']),
    (tipo: tipoRojo, casillas: ['B3', 'C3', 'A4', 'B4', 'C4', 'B5']),
    (tipo: tipoRojo, casillas: ['F3', 'E4', 'F4', 'G4', 'E5', 'F5']),
    (tipo: tipoGris, casillas: ['D1', 'D7']),
  ],
);

/// El "Level 3": franjas de colores, con una zona gris de 5 casillas
/// dispersas.
const nivel3 = Mapa(
  nivel: 3,
  casillasIniciales: ['C1', 'F2', 'B4', 'E4', 'C6', 'E7'],
  zonas: [
    (tipo: tipoAmarillo, casillas: ['A1', 'B1', 'B2', 'F1', 'G1', 'F2']),
    (tipo: tipoVerde, casillas: ['A5', 'G5', 'A6', 'B6', 'C6', 'D6', 'E6', 'F6', 'G6']),
    (tipo: tipoAzul, casillas: ['B5', 'C5', 'D5', 'E5', 'F5']),
    (tipo: tipoMorado, casillas: ['C1', 'E1', 'C2', 'D2', 'E2', 'D3']),
    (tipo: tipoMorado, casillas: ['A7', 'B7', 'C7', 'E7', 'F7', 'G7']),
    (tipo: tipoRojo, casillas: ['A3', 'B3', 'C3', 'A4', 'B4', 'C4']),
    (tipo: tipoRojo, casillas: ['E3', 'F3', 'G3', 'E4', 'F4', 'G4']),
    (tipo: tipoGris, casillas: ['D1', 'A2', 'G2', 'D4', 'D7']),
  ],
);

/// El "Level 4": la fila de arriba es una zona naranja "4-6" y la de abajo
/// una "1-3". Por eso sus casillas iniciales no son las de los otros mapas:
/// C1 y E7 caerían en las naranjas, y E4 y C6 en la misma zona azul.
const nivel4 = Mapa(
  nivel: 4,
  casillasIniciales: ['C2', 'F2', 'B4', 'D4', 'B6', 'G6'],
  zonas: [
    (tipo: tipoAmarillo, casillas: ['A2', 'G2', 'A4', 'G4', 'A6', 'G6']),
    (tipo: tipoVerde, casillas: ['D2', 'B4', 'F4', 'D6']),
    (tipo: tipoAzul, casillas: ['C2', 'E2', 'C4', 'E4', 'C6', 'E6']),
    (tipo: tipoMorado, casillas: ['C3', 'D3', 'E3', 'D4', 'C5', 'D5', 'E5']),
    (tipo: tipoRojo, casillas: ['B2', 'A3', 'B3', 'A5', 'B5', 'B6']),
    (tipo: tipoRojo, casillas: ['F2', 'F3', 'G3', 'F5', 'G5', 'F6']),
    (tipo: tipoNaranjaAlto, casillas: ['A1', 'B1', 'C1', 'D1', 'E1', 'F1', 'G1']),
    (tipo: tipoNaranjaBajo, casillas: ['A7', 'B7', 'C7', 'D7', 'E7', 'F7', 'G7']),
  ],
);
