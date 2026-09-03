import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_maximo_valores_distintos.dart';

void main() {
  group('puedeAgregarConMaximoValoresDistintos', () {
    test('permite el primer número en una zona vacía', () {
      expect(puedeAgregarConMaximoValoresDistintos([], 5, 2), isTrue);
    });

    test('permite repetir un valor ya presente', () {
      expect(puedeAgregarConMaximoValoresDistintos([3, 3], 3, 2), isTrue);
    });

    test('permite introducir un segundo valor distinto', () {
      expect(puedeAgregarConMaximoValoresDistintos([3, 3], 5, 2), isTrue);
    });

    test('rechaza un tercer valor distinto cuando el máximo es 2', () {
      expect(puedeAgregarConMaximoValoresDistintos([3, 5], 6, 2), isFalse);
    });

    test('respeta un máximo distinto de 2', () {
      expect(puedeAgregarConMaximoValoresDistintos([1, 2, 3], 4, 4), isTrue);
      expect(puedeAgregarConMaximoValoresDistintos([1, 2, 3], 4, 3), isFalse);
    });
  });
}
