import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';
import 'ayudantes_servidores.dart';

void main() {
  testWidgets('PantallaEntrar: con varios servidores en la red se ve la lista, "Entrar" espera, '
      'y al tocar uno se habilita', (tester) async {
    await abrirConVariosServidores(tester);

    expect(listaDeVarios, findsOneWidget);
    expect(find.text('Brilliant en ORION'), findsOneWidget);
    expect(find.text('Brilliant en VEGA'), findsOneWidget);
    expect(habilitado(tester, botonEntrar), isFalse);
    expect(indicadorDelServidor(tester), startsWith('Hay varios servidores'));

    await tocar(tester, find.byKey(const ValueKey('servidor-192.168.137.41')));

    expect(listaDeVarios, findsNothing);
    expect(habilitado(tester, botonEntrar), isTrue);
    expect(indicadorDelServidor(tester), contains('Brilliant en VEGA'));
    await entrarCon(tester, 'ana', contrasenaDePrueba);
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
