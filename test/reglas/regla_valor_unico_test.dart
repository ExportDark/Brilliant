import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_valor_unico.dart';

void main() {
  group('puedeAgregarValorUnico', () {
    test('permite el primer número en una zona vacía', () {
      expect(puedeAgregarValorUnico([], 5), isTrue);
    });

    test('permite repetir el valor único ya establecido', () {
      expect(puedeAgregarValorUnico([2, 2], 2), isTrue);
    });

    test('rechaza un valor distinto al ya establecido', () {
      expect(puedeAgregarValorUnico([2, 2], 3), isFalse);
    });
  });
}
