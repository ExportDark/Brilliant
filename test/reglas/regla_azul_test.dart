import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_azul.dart';

void main() {
  group('ReglaAzul', () {
    const regla = ReglaAzul();

    test('permite anotar en una zona azul vacía', () {
      expect(regla.puedeAgregar([], 4), isTrue);
    });

    test('rechaza un valor distinto al ya establecido en la zona', () {
      expect(regla.puedeAgregar([4, 4], 1), isFalse);
    });

    test('coincide con los datos de la Partida 1 del manual (zona azul C1-C2-D3 con valor 4)', () {
      final valoresYaAnotados = <int>[];
      for (final valor in [4, 4, 4]) {
        expect(regla.puedeAgregar(valoresYaAnotados, valor), isTrue);
        valoresYaAnotados.add(valor);
      }
    });
  });
}
