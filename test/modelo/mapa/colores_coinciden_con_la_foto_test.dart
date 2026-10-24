import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

/// El color de las 49 casillas de cada mapa, fila por fila, leído de las
/// tarjetas de la foto. Está escrito aparte del código a propósito: si una
/// zona del mapa se transcribió mal, este test lo nota.
const _tarjetas = {
  1: [
    'Am Ve Az Mo Mo Mo Am',
    'Ve Ve Az Az Mo Mo Ve',
    'Ve Ro Ro Az Mo Ve Ve',
    'Ve Ro Mo Am Ve Ve Ve',
    'Ve Ro Mo Mo Ro Ro Az',
    'Ro Ro Mo Ro Ro Az Az',
    'Am Mo Mo Ro Ro Az Am',
  ],
  2: [
    'Mo Mo Mo Gr Ve Ve Ve',
    'Mo Am Az Az Az Am Ve',
    'Mo Ro Ro Az Az Ro Ve',
    'Ro Ro Ro Am Ro Ro Ro',
    'Ve Ro Az Az Ro Ro Mo',
    'Ve Am Az Az Az Am Mo',
    'Ve Ve Ve Gr Mo Mo Mo',
  ],
  3: [
    'Am Am Mo Gr Mo Am Am',
    'Gr Am Mo Mo Mo Am Gr',
    'Ro Ro Ro Mo Ro Ro Ro',
    'Ro Ro Ro Gr Ro Ro Ro',
    'Ve Az Az Az Az Az Ve',
    'Ve Ve Ve Ve Ve Ve Ve',
    'Mo Mo Mo Gr Mo Mo Mo',
  ],
  4: [
    'Na Na Na Na Na Na Na',
    'Am Ro Az Ve Az Ro Am',
    'Ro Ro Mo Mo Mo Ro Ro',
    'Am Ve Az Mo Az Ve Am',
    'Ro Ro Mo Mo Mo Ro Ro',
    'Am Ro Az Ve Az Ro Am',
    'Na Na Na Na Na Na Na',
  ],
};

const _colores = {
  'Am': ColorZona.amarillo,
  'Ve': ColorZona.verde,
  'Az': ColorZona.azul,
  'Mo': ColorZona.morado,
  'Ro': ColorZona.rojo,
  'Gr': ColorZona.gris,
  'Na': ColorZona.naranja,
};

void main() {
  for (final mapa in mapas) {
    test('${mapa.nombre}: el color de cada casilla coincide con su tarjeta', () {
      final tablero = Tablero.desdeMapa(mapa);
      final filas = _tarjetas[mapa.nivel]!;

      for (var fila = 0; fila < Tablero.filas; fila++) {
        final colores = filas[fila].split(' ');
        for (var columna = 0; columna < Tablero.columnas; columna++) {
          final posicion = Posicion(fila: fila, columna: columna);
          expect(
            tablero.celdaEn(posicion)!.color,
            _colores[colores[columna]],
            reason: '${mapa.nombre}, ${posicion.notacion}',
          );
        }
      }
    });
  }
}
