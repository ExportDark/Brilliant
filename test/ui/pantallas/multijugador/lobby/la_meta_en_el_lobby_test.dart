import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

String metaEnElLobby(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('meta-de-la-sala'))).data!;

void main() {
  testWidgets('El lobby dice a cuántos puntos se gana, y la meta baja cuando entran más', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba(meta: 26));

    expect(
      metaEnElLobby(tester),
      'Gana el primero que llegue a 26 puntos. Con más jugadores, la meta baja.',
    );

    salas.vista = vistaDePrueba(
      version: 2,
      meta: 24,
      jugadores: [jugadorJson('ana', anfitrion: true), jugadorJson('beto'), jugadorJson('carla')],
    );
    await pasarSegundos(tester, 1);

    expect(metaEnElLobby(tester), startsWith('Gana el primero que llegue a 24 puntos.'));
  });
}
