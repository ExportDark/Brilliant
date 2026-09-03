import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_morado.dart';

void main() {
  group('ReglaMorado', () {
    const regla = ReglaMorado();

    test('permite anotar en una zona morada vacía', () {
      expect(regla.puedeAgregar([], 2), isTrue);
    });

    test('permite un segundo valor distinto', () {
      expect(regla.puedeAgregar([2], 5), isTrue);
    });

    test('permite repetir cualquiera de los dos valores ya establecidos', () {
      expect(regla.puedeAgregar([2, 5, 2], 5), isTrue);
    });

    test('rechaza un tercer valor distinto', () {
      expect(regla.puedeAgregar([2, 5], 6), isFalse);
    });
  });
}
