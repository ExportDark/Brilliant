import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import 'ayudantes_tiempos.dart';

void main() {
  testWidgets('Mientras se reparten los números, la cuenta del título baja cada segundo', (
    tester,
  ) async {
    final (salas: _, :pasar) = await abrirConReloj(
      tester,
      vistaDePrueba(estado: 'preparando', segundosRestantes: 60),
    );
    expect(find.text('Reparte tus números · 60 s'), findsOneWidget);

    await pasar(4);

    expect(find.text('Reparte tus números · 56 s'), findsOneWidget);
  });

  testWidgets('Esperando a los demás, la cuenta también baja', (tester) async {
    final (salas: _, :pasar) = await abrirConReloj(
      tester,
      vistaDePrueba(estado: 'preparando', preparado: true, segundosRestantes: 41),
    );
    final esperando = find.byKey(const ValueKey('esperando-la-preparacion'));
    expect(textoDe(tester, esperando), 'Listo. Esperando a los demás… · 41 s');

    await pasar(6);

    expect(textoDe(tester, esperando), 'Listo. Esperando a los demás… · 35 s');
  });
}
