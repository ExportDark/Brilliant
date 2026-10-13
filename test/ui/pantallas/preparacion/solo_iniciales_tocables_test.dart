import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/tablero.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPreparacion: en el tablero solo se pueden tocar las 6 casillas iniciales', (
    tester,
  ) async {
    await abrirPreparacion(tester);

    final tocables = {
      for (final widget in tester.allWidgets)
        if (widget.key case ValueKey<String>(:final value) when value.startsWith('casilla-'))
          value.substring('casilla-'.length),
    };

    expect(tocables, casillasIniciales);
  });
}
