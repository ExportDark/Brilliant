import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/ui/widgets/hoja_de_reglas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../multijugador/ayudantes_salas.dart';
import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('En línea, la hoja de reglas dice a cuántos puntos se gana', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: HojaDeReglas(mapa: nivel2, enLinea: true, meta: 24))),
    );

    expect(find.textContaining('gana el primero que llegue a 24 puntos'), findsOneWidget);
  });

  testWidgets('El botón "Reglas" de la partida en línea abre la hoja con la meta de la sala', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, partidaEnJuego());

    await tocar(tester, find.byKey(const ValueKey('boton-reglas')));

    expect(find.textContaining('gana el primero que llegue a 26 puntos'), findsOneWidget);
  });
}
