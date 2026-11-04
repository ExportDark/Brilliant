import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('DialogoDelServidor: si no encuentra ninguno lo dice, y se puede buscar de nuevo',
      (tester) async {
    final servidor = ServidorFalso();
    final buscador = BuscadorFalso();
    await abrirApp(tester, servidor: servidor, conSesion: false, buscador: buscador);

    await tocar(tester, botonServidor);
    expect(find.textContaining('No se encontró ningún servidor'), findsOneWidget);

    // Se enciende el servidor en otra PC de la red.
    servidor.direccion = '192.168.137.252';
    buscador.anunciados.add(anunciado('192.168.137.252'));
    await tocar(tester, find.widgetWithText(TextButton, 'Buscar de nuevo'));

    expect(find.textContaining('No se encontró ningún servidor'), findsNothing);
    expect(find.text('Brilliant en ORION'), findsOneWidget);
    expect(buscador.busquedas, 2);
  });
}
