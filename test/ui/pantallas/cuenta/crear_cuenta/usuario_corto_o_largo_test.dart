import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/reglas_de_cuenta.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaCrearCuenta: el usuario va de 3 a 20 caracteres', (tester) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor, conSesion: false);
    await tocar(tester, enlaceCrearCuenta);

    await crearCuentaCon(tester, 'an', contrasenaDePrueba);
    expect(errorDelCampo(tester, 'campo-usuario-nuevo'), usuarioDeOtroLargo);
    expect(servidor.cuentas, isEmpty);

    // No deja escribir más de 20: el resto no entra.
    await escribir(tester, 'campo-usuario-nuevo', 'gema-brillante-de-la-cueva');
    final campo = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('campo-usuario-nuevo')),
        matching: find.byType(TextField),
      ),
    );
    expect(campo.controller!.text, 'gema-brillante-de-la');

    await tocar(tester, botonCrearCuenta);
    expect(find.text('Elige un mapa'), findsOneWidget);
    expect(servidor.cuentas.keys, ['gema-brillante-de-la']);
  });
}
