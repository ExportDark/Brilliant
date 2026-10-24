import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/tipo_region.dart';

void main() {
  test('ReglaColor.descripcion: cada color se describe con el nombre de su regla del manual', () {
    // Es lo que lee el jugador cuando una casilla no acepta su número.
    expect(tipoRojo.regla.descripcion, startsWith('Todos diferentes'));
    expect(tipoAmarillo.regla.descripcion, startsWith('Todos diferentes'));
    expect(tipoVerde.regla.descripcion, startsWith('Cualquiera'));
    expect(tipoAzul.regla.descripcion, startsWith('Todos iguales'));
    expect(tipoMorado.regla.descripcion, startsWith('Solo dos números diferentes'));
    expect(tipoGris.regla.descripcion, startsWith('Todos iguales'));
    expect(tipoNaranjaBajo.regla.descripcion, 'Solo del 1 al 3');
    expect(tipoNaranjaAlto.regla.descripcion, 'Solo del 4 al 6');
  });
}
