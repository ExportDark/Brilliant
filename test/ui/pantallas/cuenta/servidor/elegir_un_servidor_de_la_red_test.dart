import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('DialogoDelServidor: busca los servidores de la red y basta con tocar uno',
      (tester) async {
    final servidor = ServidorFalso();
    final buscador = BuscadorFalso(
      [anunciado('192.168.137.252')],
      const Duration(seconds: 1),
    );
    await abrirApp(tester, servidor: servidor, conSesion: false, buscador: buscador);

    // La PC cambió de red.
    servidor.direccion = '192.168.137.252';
    await tester.tap(botonServidor);
    await tester.pump();
    await tester.pump();
    expect(find.text('Buscando servidores…'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Buscando servidores…'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Brilliant en ORION'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Disponible · 192.168.137.252'), findsOneWidget);

    await tocar(tester, find.byKey(const ValueKey('servidor-192.168.137.252')));
    expect(
      indicadorDelServidor(tester),
      'Servidor disponible · Brilliant en ORION · 192.168.137.252',
    );

    // Al volver a abrirlo, el que se usa lleva la palomita.
    await tocar(tester, botonServidor);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('servidor-192.168.137.252')),
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsOneWidget,
    );
  });
}
