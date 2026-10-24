import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/reglas/regla_gris.dart';

void main() {
  group('ReglaGris', () {
    const regla = ReglaGris();

    test('permite anotar cualquier número en una zona gris vacía', () {
      for (var numero = 1; numero <= 6; numero++) {
        expect(regla.puedeAgregar([], numero), isTrue, reason: 'el $numero');
      }
    });

    test('después, solo acepta el mismo número', () {
      expect(regla.puedeAgregar([3], 3), isTrue);
      expect(regla.puedeAgregar([3, 3], 5), isFalse);
    });

    test('se describe como "Todos iguales", igual que la azul', () {
      expect(regla.descripcion, startsWith('Todos iguales'));
    });
  });
}
