import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

/// Las casillas iniciales elegidas para cada mapa. Las tarjetas no las marcan:
/// los niveles 2 y 3 usan las del Nivel 1, y el Nivel 4 unas propias.
const _inicialesPorNivel = {
  1: ['C1', 'F2', 'B4', 'E4', 'C6', 'E7'],
  2: ['C1', 'F2', 'B4', 'E4', 'C6', 'E7'],
  3: ['C1', 'F2', 'B4', 'E4', 'C6', 'E7'],
  4: ['C2', 'F2', 'B4', 'D4', 'B6', 'G6'],
};

void main() {
  for (final mapa in mapas) {
    test('${mapa.nombre}: 6 casillas iniciales, cada una en una zona distinta y ninguna '
        'en una zona naranja', () {
      final tablero = Tablero.desdeMapa(mapa);
      Posicion pos(String notacion) => Posicion.desdeNotacion(notacion);

      expect(mapa.casillasIniciales, _inicialesPorNivel[mapa.nivel]);

      // En zonas distintas, ningún reparto del 1 al 6 rompe una regla al
      // empezar: por ejemplo, dos iniciales en una misma zona azul tendrían
      // que llevar el mismo número, y los 6 números son distintos.
      final zonas = {
        for (final casilla in mapa.casillasIniciales) tablero.regionEn(pos(casilla))!.identificador,
      };
      expect(zonas, hasLength(6));

      // Una zona naranja no acepta cualquier número del 1 al 6.
      for (final casilla in mapa.casillasIniciales) {
        expect(tablero.celdaEn(pos(casilla))!.color, isNot(ColorZona.naranja), reason: casilla);
      }

      // Y el tablero marca exactamente esas como iniciales.
      expect(
        {for (final celda in tablero.celdas) if (celda.esInicial) celda.posicion.notacion},
        mapa.casillasIniciales.toSet(),
      );
    });
  }
}
