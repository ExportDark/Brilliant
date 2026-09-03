import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_numeros_distintos.dart';

void main() {
  group('puedeAgregarManteniendoDistintos', () {
    test('permite el primer número en una zona vacía', () {
      expect(puedeAgregarManteniendoDistintos([], 4), isTrue);
    });

    test('permite un número que no está repetido', () {
      expect(puedeAgregarManteniendoDistintos([1, 2, 3], 4), isTrue);
    });

    test('rechaza un número ya presente en la zona', () {
      expect(puedeAgregarManteniendoDistintos([1, 2, 3], 2), isFalse);
    });

    test('permite completar una corrida del 1 al 6', () {
      expect(puedeAgregarManteniendoDistintos([1, 2, 3, 4, 5], 6), isTrue);
    });

    test('rechaza repetir el último número disponible en una corrida casi completa', () {
      expect(puedeAgregarManteniendoDistintos([1, 2, 3, 4, 5], 5), isFalse);
    });
  });
}
