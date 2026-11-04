import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: si cambia la red, vuelve a buscar el servidor y muestra dónde está',
      (tester) async {
    final servidor = ServidorFalso();
    final buscador = BuscadorFalso();
    final cambiosDeRed = StreamController<Object?>();
    addTearDown(cambiosDeRed.close);
    await abrirApp(
      tester,
      servidor: servidor,
      conSesion: false,
      buscador: buscador,
      cambiosDeRed: cambiosDeRed.stream,
    );
    expect(indicadorDelServidor(tester), 'Servidor disponible · servidor.test');

    // El celular y la PC se pasan a otra WiFi: el servidor ahora se anuncia en
    // la IP nueva, y en la vieja ya no contesta.
    servidor.direccion = '192.168.137.252';
    buscador.anunciados.add(anunciado('192.168.137.252'));
    cambiosDeRed.add(null);
    await tester.pumpAndSettle();

    expect(
      indicadorDelServidor(tester),
      'Servidor disponible · Brilliant en ORION · 192.168.137.252',
    );
  });
}
