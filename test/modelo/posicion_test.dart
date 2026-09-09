import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/posicion.dart';

void main() {
  group('Posicion', () {
    test('dos posiciones con la misma fila y columna son iguales', () {
      const a = Posicion(fila: 2, columna: 3);
      const b = Posicion(fila: 2, columna: 3);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('posiciones con distinta fila o columna no son iguales', () {
      const a = Posicion(fila: 2, columna: 3);
      const b = Posicion(fila: 3, columna: 2);

      expect(a, isNot(equals(b)));
    });
  });
}
