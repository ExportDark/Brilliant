import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_rojo.dart';

void main() {
  group('ReglaRojo', () {
    const regla = ReglaRojo();

    test('permite anotar en una zona roja vacía', () {
      expect(regla.puedeAgregar([], 1), isTrue);
    });

    test('permite anotar un valor no repetido', () {
      expect(regla.puedeAgregar([1, 2, 3], 4), isTrue);
    });

    test('rechaza repetir un valor ya anotado en la zona', () {
      expect(regla.puedeAgregar([1, 2, 3], 3), isFalse);
    });
  });
}
