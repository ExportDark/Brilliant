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

    test('rechaza construirse con una cantidad de celdas distinta a la del tipo', () {
      expect(
        () => Region(
          identificador: 1,
          tipo: tipoAzul,
          casillas: [_celdaAzul(0), _celdaAzul(1), _celdaAzul(2)],
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
