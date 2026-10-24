import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/tablero.dart';

/// Cuántas casillas tiene cada zona de cada color, contadas en las tarjetas
/// de los mapas: una entrada por zona, de menor a mayor.
const _tamanosPorNivel = {
  1: {
    ColorZona.amarillo: [5],
    ColorZona.verde: [6, 6],
    ColorZona.azul: [4, 4],
    ColorZona.morado: [6, 6],
    ColorZona.rojo: [6, 6],
  },
  2: {
    ColorZona.amarillo: [5],
    ColorZona.verde: [5, 5],
    ColorZona.azul: [5, 5],
    ColorZona.morado: [5, 5],
    ColorZona.rojo: [6, 6],
    ColorZona.gris: [2],
  },
  3: {
    ColorZona.amarillo: [6],
    ColorZona.verde: [9],
    ColorZona.azul: [5],
    ColorZona.morado: [6, 6],
    ColorZona.rojo: [6, 6],
    ColorZona.gris: [5],
  },
  4: {
    ColorZona.amarillo: [6],
    ColorZona.verde: [4],
    ColorZona.azul: [6],
    ColorZona.morado: [7],
    ColorZona.rojo: [6, 6],
    ColorZona.naranja: [7, 7],
  },
};

void main() {
  test('mapas: son los 4 niveles, en orden y con su nombre', () {
    expect([for (final mapa in mapas) mapa.nivel], [1, 2, 3, 4]);
    expect([for (final mapa in mapas) mapa.nombre], ['Nivel 1', 'Nivel 2', 'Nivel 3', 'Nivel 4']);
  });

  for (final mapa in mapas) {
    group('Mapa ${mapa.nombre}', () {
      test('se arma sin violar ninguna validación del layout', () {
        expect(() => Tablero.desdeMapa(mapa), returnsNormally);
      });

      test('tiene 49 casillas y todas empiezan vacías', () {
        final tablero = Tablero.desdeMapa(mapa);

        expect(tablero.celdas, hasLength(49));
        expect(tablero.celdas.every((celda) => celda.estaVacia), isTrue);
      });

      test('cada color tiene las zonas y los tamaños de su tarjeta', () {
        final tamanos = <ColorZona, List<int>>{};
        for (final region in Tablero.desdeMapa(mapa).regiones) {
          tamanos.putIfAbsent(region.tipo.color, () => []).add(region.casillas.length);
        }

        expect(
          {for (final MapEntry(:key, :value) in tamanos.entries) key: value..sort()},
          _tamanosPorNivel[mapa.nivel],
        );
      });

      test('las regiones se numeran desde 1, en el orden en que el mapa declara sus zonas', () {
        final regiones = Tablero.desdeMapa(mapa).regiones;

        expect(
          [for (final region in regiones) region.identificador],
          [for (var numero = 1; numero <= mapa.zonas.length; numero++) numero],
        );
      });
    });
  }
}
