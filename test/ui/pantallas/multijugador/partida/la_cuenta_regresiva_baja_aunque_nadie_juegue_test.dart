import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

String tiempoEnPantalla(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('ronda-y-tiempo'))).data!;

void main() {
  testWidgets('La cuenta regresiva de la ronda baja cada segundo aunque el servidor conteste '
      '"no cambió nada" (antes se quedaba congelada)', (tester) async {
    final salas = SalasFalsas()..vista = partidaEnJuego();
    var ahora = DateTime(2026, 11, 10, 12);
    await abrirSalaSola(tester, salas, ahora: () => ahora);
    await tocar(tester, find.byKey(const ValueKey('boton-crear-sala')));
    expect(tiempoEnPantalla(tester), 'Ronda 1 · 60 s');

    // Nadie juega: el servidor contesta siempre la misma versión.
    for (var i = 0; i < 3; i++) {
      ahora = ahora.add(const Duration(seconds: 1));
      await pasarSegundos(tester, 1);
    }

    expect(salas.preguntas, greaterThanOrEqualTo(3));
    expect(tiempoEnPantalla(tester), 'Ronda 1 · 57 s');
  });

  testWidgets('Sin conexión el tiempo de la ronda también sigue bajando', (tester) async {
    final salas = SalasFalsas()..vista = partidaEnJuego();
    var ahora = DateTime(2026, 11, 10, 12);
    await abrirSalaSola(tester, salas, ahora: () => ahora);
    await tocar(tester, find.byKey(const ValueKey('boton-crear-sala')));

    salas.sinConexion = true;
    for (var i = 0; i < 5; i++) {
      ahora = ahora.add(const Duration(seconds: 1));
      await pasarSegundos(tester, 1);
    }

    expect(tiempoEnPantalla(tester), 'Ronda 1 · 55 s');
  });

  testWidgets('Cuando llega una sala nueva, el tiempo es el que dice el servidor', (tester) async {
    final salas = SalasFalsas()..vista = partidaEnJuego();
    var ahora = DateTime(2026, 11, 10, 12);
    await abrirSalaSola(tester, salas, ahora: () => ahora);
    await tocar(tester, find.byKey(const ValueKey('boton-crear-sala')));
    ahora = ahora.add(const Duration(seconds: 20));
    await pasarSegundos(tester, 1);
    expect(tiempoEnPantalla(tester), 'Ronda 1 · 40 s');

    // Empieza la ronda 2: el servidor manda 60 s otra vez.
    salas.vista = vistaDePrueba(
      version: 9,
      estado: 'jugando',
      ronda: 2,
      dados: const [2, 5],
      segundosRestantes: 60,
    );
    ahora = ahora.add(const Duration(seconds: 1));
    await pasarSegundos(tester, 1);

    expect(tiempoEnPantalla(tester), 'Ronda 2 · 60 s');
  });
}
