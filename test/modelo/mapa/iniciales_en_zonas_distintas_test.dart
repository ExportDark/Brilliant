import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

/// Las casillas iniciales de cada mapa: las que en la tarjeta llevan una
/// estrellita.
const _estrellasPorNivel = {
  1: ['C1', 'F2', 'B4', 'E4', 'C6', 'E7'],
  2: ['E1', 'A3', 'C4', 'F5', 'B6', 'E7'],
  3: ['C2', 'F2', 'D4', 'B5', 'G5', 'C7'],
  4: ['E1', 'C3', 'F3', 'A4', 'E6', 'B7'],
};

void main() {
  for (final mapa in mapas) {
    test('${mapa.nombre}: las 6 casillas iniciales son las de la estrellita, cada una en una '
        'zona distinta', () {
      final tablero = Tablero.desdeMapa(mapa);
      Posicion pos(String notacion) => Posicion.desdeNotacion(notacion);

      expect(mapa.casillasIniciales, _estrellasPorNivel[mapa.nivel]);

      // Las reglas piden los 6 números en 6 zonas distintas: por ejemplo, dos
      // iniciales en una misma zona azul tendrían que llevar el mismo número, y
      // los 6 números son distintos.
      final zonas = {
        for (final casilla in mapa.casillasIniciales) tablero.regionEn(pos(casilla))!.identificador,
      };
      expect(zonas, hasLength(6));

      // Y el tablero marca exactamente esas como iniciales.
      expect(
        {for (final celda in tablero.celdas) if (celda.esInicial) celda.posicion.notacion},
        mapa.casillasIniciales.toSet(),
      );
    });
  }
}
