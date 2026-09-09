import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/celda.dart';
import 'package:brilliant/modelo/extraer_valores.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/region.dart';
import 'package:brilliant/modelo/tipo_region.dart';

Celda _celdaVerde(int columna, {int? valor}) {
  return Celda(posicion: Posicion(fila: 0, columna: columna), color: tipoVerde.color, valor: valor);
}

void main() {
  group('extraerValores', () {
    test('devuelve lista vacía si la región no tiene ninguna celda llena', () {
      final region = Region(
        identificador: 1,
        tipo: tipoVerde,
        casillas: List.generate(6, (i) => _celdaVerde(i)),
      );

      expect(extraerValores(region), isEmpty);
    });

    test('excluye las celdas vacías y conserva el orden de las llenas', () {
      final region = Region(
        identificador: 1,
        tipo: tipoVerde,
        casillas: [
          _celdaVerde(0, valor: 3),
          _celdaVerde(1),
          _celdaVerde(2, valor: 5),
          _celdaVerde(3),
          _celdaVerde(4, valor: 5),
          _celdaVerde(5),
        ],
      );

      expect(extraerValores(region), [3, 5, 5]);
    });

    test('devuelve todos los valores cuando la región está completa', () {
      final region = Region(
        identificador: 1,
        tipo: tipoVerde,
        casillas: [
          _celdaVerde(0, valor: 1),
          _celdaVerde(1, valor: 2),
          _celdaVerde(2, valor: 3),
          _celdaVerde(3, valor: 4),
          _celdaVerde(4, valor: 5),
          _celdaVerde(5, valor: 6),
        ],
      );

      expect(extraerValores(region), [1, 2, 3, 4, 5, 6]);
    });
  });
}
