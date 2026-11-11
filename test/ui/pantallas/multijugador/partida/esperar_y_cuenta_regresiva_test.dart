import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Después de anotar se espera a los demás, y nada responde al toque', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(tester, salas, partidaEnJuego(accion: 'coloco'));

    expect(find.text('Anotaste. Esperando a los demás…'), findsOneWidget);
    expect(celdasDibujadasDonde(tester, (c) => c.iluminacion == Iluminacion.posible), isEmpty);
    expect(find.byKey(const ValueKey('boton-pasar')), findsNothing);
  });

  testWidgets('Quien ya jugó aparece con una palomita, y quien no, esperando', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'jugando',
        ronda: 1,
        dados: const [1, 3],
        segundosRestantes: 60,
        jugadores: [
          jugadorJson('ana', anfitrion: true, listo: true),
          jugadorJson('beto'),
          jugadorJson('carla', listo: true),
        ],
      ),
    );

    expect(tester.widget<Icon>(find.byKey(const ValueKey('listo-ana'))).icon, Icons.check_circle_rounded);
    expect(tester.widget<Icon>(find.byKey(const ValueKey('listo-beto'))).icon, Icons.hourglass_empty_rounded);
    expect(tester.widget<Icon>(find.byKey(const ValueKey('listo-carla'))).icon, Icons.check_circle_rounded);
  });

  testWidgets('La cuenta regresiva baja con lo que contesta el servidor', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, partidaEnJuego());
    expect(find.text('Ronda 1 · 60 s'), findsOneWidget);

    salas.vista = vistaDePrueba(
      version: 7,
      estado: 'jugando',
      ronda: 1,
      dados: const [1, 3],
      segundosRestantes: 41.2,
    );
    await pasarSegundos(tester, 1);

    expect(find.text('Ronda 1 · 42 s'), findsOneWidget);
  });

  testWidgets('Si no tengo dónde anotar el servidor me pasa solo, y se ve', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(tester, salas, partidaEnJuego(accion: 'paso', jugadas: const []));

    expect(find.text('No tenías dónde anotar: pasaste esta ronda.'), findsOneWidget);
  });

  testWidgets('Pasar el turno aparece solo cuando el servidor dice que se puede', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, partidaEnJuego());
    expect(find.byKey(const ValueKey('boton-pasar')), findsNothing);

    salas.vista = vistaDePrueba(
      version: 9,
      estado: 'jugando',
      ronda: 1,
      dados: const [1, 3],
      segundosRestantes: 50,
      jugadas: const [
        {'ancla': 1, 'valor': 3, 'casillas': <String>[]},
      ],
      puedePasar: true,
    );
    await pasarSegundos(tester, 1);

    expect(find.byKey(const ValueKey('boton-pasar')), findsOneWidget);
    await tocar(tester, find.byKey(const ValueKey('boton-pasar')));
    expect(salas.llamadas, contains('pasar 1'));
  });

  testWidgets('Un doble toque en una casilla no manda dos jugadas', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, partidaEnJuego());
    await tocar(tester, find.byKey(const ValueKey('dado-0')));

    await tester.tap(casillaTocable('D1'));
    await tester.tap(casillaTocable('D1'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // El bloc atiende de a uno; el servidor responde "ya jugaste" al segundo y la
    // pantalla no muestra error.
    expect(errorDeSala, findsNothing);
  });
}
