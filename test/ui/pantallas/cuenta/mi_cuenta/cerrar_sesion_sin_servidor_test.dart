import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Mi cuenta: si el servidor no contesta al cerrar sesión, se cierra aquí sin '
      'aviso, y al volver a entrar con la misma cuenta, entra', (tester) async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(
      tester,
      servidor: servidor,
      conSesion: false,
      revisarCada: const Duration(seconds: 2),
    );
    await entrarCon(tester, 'ana', contrasenaDePrueba);
    expect(find.text('Elige un mapa'), findsOneWidget);

    // Se cierra sesión justo cuando el servidor no contesta.
    servidor.apagado = true;
    await tocar(tester, botonMiCuenta);
    await tocar(tester, find.widgetWithText(FilledButton, 'Cerrar sesión'));

    expect(find.byKey(const ValueKey('aviso-de-sesion')), findsNothing);
    expect(botonEntrar, findsOneWidget);

    // El servidor vuelve, con la sesión todavía abierta. Antes daba 409.
    servidor.apagado = false;
    await pasarSegundos(tester, 3);
    expect(servidor.sesiones.values, contains('ana'));
    await entrarCon(tester, 'ana', contrasenaDePrueba);

    expect(find.text('Elige un mapa'), findsOneWidget);
    expect(find.byKey(const ValueKey('error-de-cuenta')), findsNothing);
  });
}
