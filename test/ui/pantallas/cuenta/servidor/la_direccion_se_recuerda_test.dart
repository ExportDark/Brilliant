import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: la dirección elegida se recuerda al reabrir la app', (tester) async {
    final servidor = ServidorFalso();
    final almacen = AlmacenEnMemoria();
    await abrirApp(tester, servidor: servidor, almacen: almacen);
    servidor.direccion = '192.168.137.252';
    await cambiarServidor(tester, '192.168.137.252');

    // Se cierra la app y se vuelve a abrir, con lo que quedó guardado.
    await tester.pumpWidget(const SizedBox());
    await abrirApp(tester, servidor: servidor, almacen: almacen);

    expect(find.text('Servidor: 192.168.137.252'), findsOneWidget);
  });
}
