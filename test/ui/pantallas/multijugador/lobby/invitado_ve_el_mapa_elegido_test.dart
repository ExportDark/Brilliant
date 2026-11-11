import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/tablero_widget.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Quien no es el anfitrión ve solo el mapa elegido, sin poder cambiarlo, y se '
      'actualiza cuando el anfitrión elige otro', (tester) async {
    final salas = SalasFalsas()..vista = vistaDePrueba(yo: 'beto', anfitrion: 'ana', nivel: 2);
    await abrirMultijugador(tester, salas);
    await tester.enterText(campoCodigo, 'k7m4qx');
    await tocar(tester, botonUnirse);

    expect(find.byType(TableroWidget), findsOneWidget);
    expect(find.text('Nivel 2'), findsOneWidget);
    expect(find.byKey(const ValueKey('mapa-elegido')), findsOneWidget);

    await tocar(tester, find.byKey(const ValueKey('mapa-2')));
    expect(salas.llamadas.where((l) => l.startsWith('mapa')), isEmpty);

    salas.vista = vistaDePrueba(yo: 'beto', anfitrion: 'ana', nivel: 4, version: 5);
    await pasarSegundos(tester, 1);

    expect(find.text('Nivel 4'), findsOneWidget);
    expect(find.text('Nivel 2'), findsNothing);
  });
}
