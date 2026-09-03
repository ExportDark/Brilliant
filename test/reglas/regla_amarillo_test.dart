import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_amarillo.dart';

void main() {
  group('ReglaAmarillo', () {
    const regla = ReglaAmarillo();

    test('permite anotar en la zona amarilla vacía', () {
      expect(regla.puedeAgregar([], 5), isTrue);
    });

    test('permite anotar un valor no repetido entre las celdas dispersas', () {
      expect(regla.puedeAgregar([3, 6], 4), isTrue);
    });

    test('rechaza repetir un valor ya anotado en otra celda amarilla', () {
      expect(regla.puedeAgregar([3, 6], 6), isFalse);
    });

    test('coincide con los datos de la Partida 1 del manual (celdas amarillas 3, 6, 5, 4)', () {
      final valoresYaAnotados = <int>[];
      for (final valor in [3, 6, 5, 4]) {
        expect(regla.puedeAgregar(valoresYaAnotados, valor), isTrue);
        valoresYaAnotados.add(valor);
      }
    });
  });
}
