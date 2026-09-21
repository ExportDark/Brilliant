import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/color5.dart';
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
      final casillasPorColor = <Color5, int>{};
      for (final celda in tablero.celdas) {
        casillasPorColor.update(celda.color, (n) => n + 1, ifAbsent: () => 1);
      }

      expect(casillasPorColor[Color5.amarillo], 5);
      expect(casillasPorColor[Color5.verde], 12);
      expect(casillasPorColor[Color5.azul], 8);
      expect(casillasPorColor[Color5.morado], 12);
      expect(casillasPorColor[Color5.rojo], 12);
    });

    test('el amarillo es una sola región y los demás colores tienen dos', () {
      int regionesDe(Color5 color) =>
          tablero.regiones.where((region) => region.tipo.color == color).length;

      expect(regionesDe(Color5.amarillo), 1);
      expect(regionesDe(Color5.verde), 2);
      expect(regionesDe(Color5.azul), 2);
      expect(regionesDe(Color5.morado), 2);
      expect(regionesDe(Color5.rojo), 2);
    });

    test('marca exactamente las 6 casillas iniciales del manual', () {
      final iniciales = tablero.celdas
          .where((celda) => celda.esInicial)
          .map((celda) => celda.posicion.notacion)
          .toSet();

      expect(iniciales, {'C1', 'F2', 'B4', 'E4', 'C6', 'E7'});
    });

    test('el color de cada casilla coincide con la tabla del manual', () {
      Color5 colorEn(String notacion) =>
          tablero.celdaEn(Posicion.desdeNotacion(notacion))!.color;

      expect(colorEn('A1'), Color5.amarillo);
      expect(colorEn('C1'), Color5.azul);
      expect(colorEn('D1'), Color5.morado);
      expect(colorEn('B3'), Color5.rojo);
      expect(colorEn('D4'), Color5.amarillo);
      expect(colorEn('E4'), Color5.verde);
      expect(colorEn('G5'), Color5.azul);
      expect(colorEn('C6'), Color5.morado);
      expect(colorEn('E7'), Color5.rojo);
      expect(colorEn('G7'), Color5.amarillo);
    });

    test('todas las casillas empiezan vacías y ninguna región está completada', () {
      expect(tablero.celdas.every((celda) => celda.estaVacia), isTrue);
      expect(tablero.regiones.any((region) => region.completada), isFalse);
    });

    test('regionEn devuelve la región que contiene esa casilla', () {
      final region = tablero.regionEn(Posicion.desdeNotacion('C1'))!;

      expect(region.tipo.color, Color5.azul);
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
