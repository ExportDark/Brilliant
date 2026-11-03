import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/pantalla_crear_cuenta.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaCrearCuenta: si el usuario ya existe, el error del servidor va en ese campo', (
    tester,
  ) async {
    final servidor = ServidorFalso()..cuentas['ana'] = 'la-de-otra-persona';
    await abrirApp(tester, servidor: servidor, conSesion: false);
    await tocar(tester, enlaceCrearCuenta);

    await escribir(tester, 'campo-usuario-nuevo', 'ana');
    await escribir(tester, 'campo-contrasena-nueva', contrasenaDePrueba);
    await escribir(tester, 'campo-contrasena-repetida', contrasenaDePrueba);
    await tocar(tester, botonCrearCuenta);

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('campo-usuario-nuevo')),
        matching: find.text('Ya existe un usuario con este nombre.'),
      ),
      findsOneWidget,
    );
    expect(find.byType(PantallaCrearCuenta), findsOneWidget);
    expect(servidor.cuentas['ana'], 'la-de-otra-persona');
  });
}
