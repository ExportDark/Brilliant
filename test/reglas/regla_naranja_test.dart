import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_naranja.dart';

void main() {
  group('ReglaNaranja', () {
    const bajo = ReglaNaranja(minimo: 1, maximo: 3);
    const alto = ReglaNaranja(minimo: 4, maximo: 6);

    test('la "1-3" solo acepta del 1 al 3', () {
      expect([for (var n = 1; n <= 6; n++) if (bajo.puedeAgregar([], n)) n], [1, 2, 3]);
    });

    test('la "4-6" solo acepta del 4 al 6', () {
      expect([for (var n = 1; n <= 6; n++) if (alto.puedeAgregar([], n)) n], [4, 5, 6]);
    });

    test('un número fuera del rango no cabe ni en una zona vacía', () {
      expect(alto.puedeAgregar([], 2), isFalse);
    });

    test('dentro del rango se puede repetir', () {
      final yaAnotados = <int>[];
      for (final valor in [5, 5, 4, 6, 4]) {
        expect(alto.puedeAgregar(yaAnotados, valor), isTrue, reason: 'el $valor tras $yaAnotados');
        yaAnotados.add(valor);
      }
    });

    test('se describe con su rango', () {
      expect(bajo.descripcion, 'Solo del 1 al 3');
      expect(alto.descripcion, 'Solo del 4 al 6');
    });
  });
}
