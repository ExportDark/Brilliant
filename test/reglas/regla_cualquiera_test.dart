import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_cualquiera.dart';

void main() {
  group('puedeAgregarCualquiera', () {
    test('permite cualquier número en una zona vacía', () {
      expect(puedeAgregarCualquiera([], 1), isTrue);
    });

    test('permite un número repetido', () {
      expect(puedeAgregarCualquiera([3, 3, 3], 3), isTrue);
    });

    test('permite un número distinto a los ya anotados', () {
      expect(puedeAgregarCualquiera([1, 2, 5], 6), isTrue);
    });
  });
}
