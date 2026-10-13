import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/tablero.dart';

void main() {
  test('Posicion.vecinas: en el tablero, las esquinas tienen 2, los bordes 3 y el interior 4', () {
    final tablero = Tablero.mapaOriginal();

    // Cuántas casillas hay con cada cantidad de vecinas dentro de la grilla.
    final porCantidad = <int, int>{};
    for (final celda in tablero.celdas) {
      final dentro = celda.posicion.vecinas.where((vecina) => tablero.celdaEn(vecina) != null);
      porCantidad.update(dentro.length, (total) => total + 1, ifAbsent: () => 1);
    }

    // 4 esquinas, 5 casillas por cada uno de los 4 bordes, y el interior de 5x5.
    expect(porCantidad, {2: 4, 3: 20, 4: 25});
  });
}
