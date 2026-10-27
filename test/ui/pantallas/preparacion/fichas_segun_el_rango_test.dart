import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';

import '../ayudantes_pantallas.dart';

/// Los números cuya ficha se puede tocar.
List<int> _fichasHabilitadas(WidgetTester tester) => [
      for (var valor = 1; valor <= 6; valor++)
        if (habilitado(tester, find.byKey(ValueKey('numero-$valor')))) valor,
    ];

void main() {
  testWidgets('PantallaPreparacion: en el Nivel 4, las fichas que no caben en la inicial '
      'naranja se apagan', (tester) async {
    await abrirPreparacion(tester, mapa: nivel4);

    // Arranca con E1 seleccionada: la fila "4-6".
    expect(_fichasHabilitadas(tester), [4, 5, 6]);

    await tocar(tester, casillaTocable('B7'));
    expect(_fichasHabilitadas(tester), [1, 2, 3], reason: 'B7 está en la fila "1-3"');

    await tocar(tester, casillaTocable('C3'));
    expect(_fichasHabilitadas(tester), [1, 2, 3, 4, 5, 6], reason: 'C3 no es naranja');
  });
}
