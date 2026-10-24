import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/tipo_region.dart';

void main() {
  test('ReglaColor.descripcion: ninguna regla dice cuántas casillas tiene la zona', () {
    // Un mismo color tiene zonas de distinto tamaño según el mapa: decir
    // "las 4 casillas" sería falso en otro mapa.
    for (final tipo in [
      tipoAmarillo,
      tipoVerde,
      tipoMorado,
      tipoAzul,
      tipoRojo,
      tipoGris,
      tipoNaranjaBajo,
      tipoNaranjaAlto,
    ]) {
      expect(
        tipo.regla.descripcion,
        isNot(matches(RegExp(r'\d+ casillas'))),
        reason: 'la regla ${tipo.color.name}',
      );
    }
  });
}
