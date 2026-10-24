import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_rango.dart';

void main() {
  group('puedeAgregarEnRango', () {
    test('acepta los números del rango, con los dos extremos incluidos', () {
      for (final numero in [1, 2, 3]) {
        expect(puedeAgregarEnRango(numero, 1, 3), isTrue, reason: 'el $numero');
      }
    });

    test('rechaza los números de fuera del rango', () {
      for (final numero in [4, 5, 6]) {
        expect(puedeAgregarEnRango(numero, 1, 3), isFalse, reason: 'el $numero');
      }
    });

    test('funciona igual con el rango de arriba', () {
      expect([for (var n = 1; n <= 6; n++) if (puedeAgregarEnRango(n, 4, 6)) n], [4, 5, 6]);
    });
  });
}
