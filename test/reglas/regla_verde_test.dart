import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_verde.dart';

void main() {
  group('ReglaVerde', () {
    const regla = ReglaVerde();

    test('permite anotar en una zona verde vacía', () {
      expect(regla.puedeAgregar([], 2), isTrue);
    });

    test('permite anotar un valor repetido', () {
      expect(regla.puedeAgregar([4, 4], 4), isTrue);
    });

    test('permite anotar cualquier valor sin restricción', () {
      expect(regla.puedeAgregar([1, 3, 5, 5], 6), isTrue);
    });
  });
}
