import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudantes_pantallas.dart';
import 'ayudantes_servidores.dart';

void main() {
  testWidgets('"Buscar de nuevo" en la lista: si uno se apagó, queda el otro y se usa solo', (
    tester,
  ) async {
    final servidor = await abrirConVariosServidores(tester);
    expect(listaDeVarios, findsOneWidget);

    // Se apaga uno de los dos (el que contesta en 192.168.137.40).
    servidor
      ..direccion = '192.168.137.41'
      ..otrasDirecciones.clear();
    await tocar(tester, find.byKey(const ValueKey('buscar-de-nuevo')));

    expect(listaDeVarios, findsNothing);
    expect(habilitado(tester, botonEntrar), isTrue);
  });
}
