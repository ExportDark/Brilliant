import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: con la cuenta activa en otro aparato, lo dice y no entra', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    // "ana" está jugando en otro celular.
    servidor.sesionIniciada('ana');
    await abrirApp(tester, servidor: servidor, conSesion: false);

    await entrarCon(tester, 'ana', contrasenaDePrueba);

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('error-de-cuenta')),
        matching: find.text(sesionEnOtroAparato),
      ),
      findsOneWidget,
    );
    expect(botonEntrar, findsOneWidget);
    expect(servidor.sesiones, hasLength(1), reason: 'la del otro celular sigue igual');
  });
}
