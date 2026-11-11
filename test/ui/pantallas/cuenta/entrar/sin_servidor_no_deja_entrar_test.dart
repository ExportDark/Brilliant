import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: sin servidor, "Entrar" está deshabilitado y dice qué hacer, y '
      'cuando el servidor aparece se habilita solo', (tester) async {
    final servidor = ServidorFalso()
      ..apagado = true
      ..cuentas['ana'] = contrasenaDePrueba;
    await abrirApp(
      tester,
      servidor: servidor,
      conSesion: false,
      revisarCada: const Duration(seconds: 2),
    );

    expect(habilitado(tester, botonEntrar), isFalse);
    expect(find.byKey(const ValueKey('falta-servidor')), findsOneWidget);
    expect(find.textContaining('No hay servidor'), findsOneWidget);

    servidor.apagado = false;
    await pasarSegundos(tester, 3);

    expect(habilitado(tester, botonEntrar), isTrue);
    expect(find.byKey(const ValueKey('falta-servidor')), findsNothing);
    await entrarCon(tester, 'ana', contrasenaDePrueba);
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
