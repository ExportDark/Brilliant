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

  group('Posicion.desdeNotacion', () {
    test('la letra es la columna y el número es la fila', () {
      expect(Posicion.desdeNotacion('A1'), const Posicion(fila: 0, columna: 0));
      expect(Posicion.desdeNotacion('C1'), const Posicion(fila: 0, columna: 2));
      expect(Posicion.desdeNotacion('A3'), const Posicion(fila: 2, columna: 0));
      expect(Posicion.desdeNotacion('G7'), const Posicion(fila: 6, columna: 6));
    });

    test('acepta la notación en minúsculas', () {
      expect(Posicion.desdeNotacion('c1'), Posicion.desdeNotacion('C1'));
    });

    test('rechaza notaciones mal formadas', () {
      expect(() => Posicion.desdeNotacion('1C'), throwsFormatException);
      expect(() => Posicion.desdeNotacion('C'), throwsFormatException);
      expect(() => Posicion.desdeNotacion(''), throwsFormatException);
      expect(() => Posicion.desdeNotacion('CC1'), throwsFormatException);
    });
  });

  group('Posicion.notacion', () {
    test('devuelve la posición escrita como en el manual', () {
      expect(const Posicion(fila: 0, columna: 0).notacion, 'A1');
      expect(const Posicion(fila: 0, columna: 2).notacion, 'C1');
      expect(const Posicion(fila: 6, columna: 4).notacion, 'E7');
    });

    test('convierte de ida y vuelta las 6 casillas iniciales del manual', () {
      for (final notacion in ['C1', 'F2', 'B4', 'E4', 'C6', 'E7']) {
        expect(Posicion.desdeNotacion(notacion).notacion, notacion);
      }
    });

    test('convierte de ida y vuelta las 49 posiciones del tablero', () {
      for (var fila = 0; fila < 7; fila++) {
        for (var columna = 0; columna < 7; columna++) {
          final posicion = Posicion(fila: fila, columna: columna);
          expect(Posicion.desdeNotacion(posicion.notacion), posicion);
        }
      }
    });
  });
}
