import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/ui/pantallas/multijugador/tablero_chico.dart';
import 'package:brilliant/ui/tema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Una casilla ocupada va con el color pleno de su zona, y una vacía bastante más clara, '
      'para que se distingan por la claridad y no solo por el color', () {
    for (final color in ColorZona.values) {
      final zona = coloresDeZona[color]!;
      final ocupada = TableroChico.colorDeCasilla(zona, ocupada: true);
      final vacia = TableroChico.colorDeCasilla(zona, ocupada: false);

      expect(ocupada, zona, reason: color.name);
      expect(
        vacia.computeLuminance() - ocupada.computeLuminance(),
        greaterThan(0.2),
        reason: color.name,
      );
    }
  });
}
