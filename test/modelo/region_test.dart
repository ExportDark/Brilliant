import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/celda.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/region.dart';
import 'package:brilliant/modelo/tipo_region.dart';

Celda _celdaAzul(int columna, {int? valor}) {
  return Celda(posicion: Posicion(fila: 0, columna: columna), color: tipoAzul.color, valor: valor);
}

void main() {
  group('Region', () {
    test('completada es falso si alguna celda sigue vacía', () {
      final region = Region(
        identificador: 1,
        tipo: tipoAzul,
        casillas: [
          _celdaAzul(0, valor: 4),
          _celdaAzul(1, valor: 4),
          _celdaAzul(2, valor: 4),
          _celdaAzul(3),
        ],
      );

      expect(region.completada, isFalse);
    });

    test('completada es verdadero cuando todas las celdas tienen valor', () {
      final region = Region(
        identificador: 1,
        tipo: tipoAzul,
        casillas: [
          _celdaAzul(0, valor: 4),
          _celdaAzul(1, valor: 4),
          _celdaAzul(2, valor: 4),
          _celdaAzul(3, valor: 4),
        ],
      );

      expect(region.completada, isTrue);
    });

    test('acepta zonas de cualquier tamaño: el tamaño lo pone cada mapa', () {
      // Un mismo color tiene zonas de tamaños distintos según el mapa: una
      // azul de 3 casillas es tan válida como una de 4 o de 6.
      final region = Region(
        identificador: 1,
        tipo: tipoAzul,
        casillas: [_celdaAzul(0), _celdaAzul(1), _celdaAzul(2)],
      );

      expect(region.casillas, hasLength(3));
    });
  });
}
