import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Iniciar sesión: si el servidor limita los intentos, dice cuántos segundos esperar', (
    tester,
  ) async {
    final servidor = ServidorFalso()
      ..cuentas['ana'] = contrasenaDePrueba
      ..regulaConSegundos = 42;
    await abrirApp(tester, servidor: servidor, conSesion: false);

    await entrarCon(tester, 'ana', contrasenaDePrueba);

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('error-de-cuenta')),
        matching: find.text('Demasiados intentos seguidos. Espera 42 segundos e intenta de nuevo.'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('throttled'), findsNothing);
    expect(botonEntrar, findsOneWidget);
  });
}
