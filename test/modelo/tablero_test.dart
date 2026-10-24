import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

void main() {
  group('Tablero.mapaOriginal', () {
    final tablero = Tablero.mapaOriginal();

    test('se construye sin violar ninguna validación del layout', () {
      expect(Tablero.mapaOriginal, returnsNormally);
    });

    test('tiene 9 regiones y 49 casillas', () {
      expect(tablero.regiones, hasLength(9));
      expect(tablero.celdas, hasLength(49));
    });

    test('cada color tiene la cantidad de casillas del manual', () {
      final casillasPorColor = <ColorZona, int>{};
      for (final celda in tablero.celdas) {
        casillasPorColor.update(celda.color, (n) => n + 1, ifAbsent: () => 1);
      }

      expect(casillasPorColor[ColorZona.amarillo], 5);
      expect(casillasPorColor[ColorZona.verde], 12);
      expect(casillasPorColor[ColorZona.azul], 8);
      expect(casillasPorColor[ColorZona.morado], 12);
      expect(casillasPorColor[ColorZona.rojo], 12);
    });

    test('el amarillo es una sola región y los demás colores tienen dos', () {
      int regionesDe(ColorZona color) =>
          tablero.regiones.where((region) => region.tipo.color == color).length;

      expect(regionesDe(ColorZona.amarillo), 1);
      expect(regionesDe(ColorZona.verde), 2);
      expect(regionesDe(ColorZona.azul), 2);
      expect(regionesDe(ColorZona.morado), 2);
      expect(regionesDe(ColorZona.rojo), 2);
    });

    test('marca exactamente las 6 casillas iniciales del manual', () {
      final iniciales = tablero.celdas
          .where((celda) => celda.esInicial)
          .map((celda) => celda.posicion.notacion)
          .toSet();

      expect(iniciales, {'C1', 'F2', 'B4', 'E4', 'C6', 'E7'});
    });

    test('el color de cada casilla coincide con la tabla del manual', () {
      ColorZona colorEn(String notacion) =>
          tablero.celdaEn(Posicion.desdeNotacion(notacion))!.color;

      expect(colorEn('A1'), ColorZona.amarillo);
      expect(colorEn('C1'), ColorZona.azul);
      expect(colorEn('D1'), ColorZona.morado);
      expect(colorEn('B3'), ColorZona.rojo);
      expect(colorEn('D4'), ColorZona.amarillo);
      expect(colorEn('E4'), ColorZona.verde);
      expect(colorEn('G5'), ColorZona.azul);
      expect(colorEn('C6'), ColorZona.morado);
      expect(colorEn('E7'), ColorZona.rojo);
      expect(colorEn('G7'), ColorZona.amarillo);
    });

    test('todas las casillas empiezan vacías y ninguna región está completada', () {
      expect(tablero.celdas.every((celda) => celda.estaVacia), isTrue);
      expect(tablero.regiones.any((region) => region.completada), isFalse);
    });

    test('regionEn devuelve la región que contiene esa casilla', () {
      final region = tablero.regionEn(Posicion.desdeNotacion('C1'))!;

      expect(region.tipo.color, ColorZona.azul);
      expect(
        region.casillas.map((celda) => celda.posicion.notacion),
        containsAll(['C1', 'C2', 'D2', 'D3']),
      );
    });

    test('devuelve null para una posición fuera de la grilla', () {
      expect(tablero.celdaEn(const Posicion(fila: 9, columna: 9)), isNull);
      expect(tablero.regionEn(const Posicion(fila: 9, columna: 9)), isNull);
    });
  });
}
