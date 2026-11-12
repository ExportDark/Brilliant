import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/multijugador/marcador.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

Finder fila(String usuario) => find.byKey(ValueKey('jugador-$usuario'));

double alturaDe(WidgetTester tester, String usuario) => tester.getTopLeft(fila(usuario)).dy;

/// El número del puesto que muestra la fila de [usuario].
String puestoDe(WidgetTester tester, String usuario) => tester
    .widgetList<Text>(find.descendant(of: fila(usuario), matching: find.byType(Text)))
    .first
    .data!;

Future<void> abrirConJugadores(
  WidgetTester tester,
  List<Map<String, dynamic>> jugadores, {
  List<Map<String, dynamic>>? zonas,
}) async {
  final salas = SalasFalsas();
  await abrirMultijugador(tester, salas);
  await crearSala(
    tester,
    salas,
    vistaDePrueba(
      estado: 'jugando',
      ronda: 9,
      dados: const [1, 3],
      segundosRestantes: 30,
      jugadores: jugadores,
      zonas: zonas,
    ),
  );
}

void main() {
  testWidgets('El marcador ordena por puntos, y si empatan por primeros puestos; los que se '
      'fueron van al final', (tester) async {
    await abrirConJugadores(tester, [
      jugadorJson('ana', anfitrion: true, puntos: 6),
      jugadorJson('beto', puntos: 12, primeros: 1),
      jugadorJson('carla', puntos: 12, primeros: 2),
      jugadorJson('dani', puntos: 20, estado: 'se_rindio'),
    ]);

    expect(find.byType(Marcador), findsOneWidget);
    expect(alturaDe(tester, 'carla'), lessThan(alturaDe(tester, 'beto')));
    expect(alturaDe(tester, 'beto'), lessThan(alturaDe(tester, 'ana')));
    expect(alturaDe(tester, 'ana'), lessThan(alturaDe(tester, 'dani')));
    expect(puestoDe(tester, 'carla'), '1');
    expect(puestoDe(tester, 'beto'), '2');
    expect(find.text('dani (se rindió)'), findsOneWidget);
  });

  testWidgets('Empatados en puntos y primeros comparten puesto', (tester) async {
    await abrirConJugadores(tester, [
      jugadorJson('ana', anfitrion: true, puntos: 9, primeros: 1),
      jugadorJson('beto', puntos: 9, primeros: 1),
      jugadorJson('carla', puntos: 2),
    ]);

    expect(puestoDe(tester, 'ana'), '1');
    expect(puestoDe(tester, 'beto'), '1');
    expect(puestoDe(tester, 'carla'), '3');
  });

  testWidgets('Mi fila va resaltada, y cada zona que llenó alguien es un punto de su color', (
    tester,
  ) async {
    await abrirConJugadores(
      tester,
      [
        jugadorJson('ana', anfitrion: true, puntos: 7, zonas: [4, 10]),
        jugadorJson('beto', puntos: 3, zonas: [10]),
      ],
      zonas: [
        zonaJson(id: 4, tipo: 'azul', color: 'azul', casillas: ['C1', 'C2']),
        zonaJson(id: 10, tipo: 'gris', color: 'gris', casillas: ['D1', 'D7']),
      ],
    );

    final mia = tester.widget<FilaDePuntos>(fila('ana'));
    expect(mia.mia, isTrue);
    expect(mia.zonas, hasLength(2));
    expect(tester.widget<FilaDePuntos>(fila('beto')).mia, isFalse);
    expect(tester.widget<FilaDePuntos>(fila('beto')).zonas, hasLength(1));
    expect(find.text('7 pts'), findsOneWidget);
  });

  testWidgets('Mientras nadie tiene puntos, nadie va marcado como líder', (tester) async {
    await abrirConJugadores(tester, [
      jugadorJson('ana', anfitrion: true),
      jugadorJson('beto'),
    ]);

    expect(tester.widget<FilaDePuntos>(fila('ana')).lider, isFalse);
    expect(tester.widget<FilaDePuntos>(fila('beto')).lider, isFalse);
  });

  testWidgets('Cuando suben los puntos, el marcador los cambia y reordena', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'jugando',
        ronda: 3,
        dados: const [1, 3],
        jugadores: [jugadorJson('ana', anfitrion: true, puntos: 2), jugadorJson('beto', puntos: 4)],
      ),
    );
    expect(alturaDe(tester, 'beto'), lessThan(alturaDe(tester, 'ana')));

    salas.vista = vistaDePrueba(
      version: 9,
      estado: 'jugando',
      ronda: 4,
      dados: const [2, 5],
      jugadores: [jugadorJson('ana', anfitrion: true, puntos: 9), jugadorJson('beto', puntos: 4)],
    );
    await pasarSegundos(tester, 1);
    await tester.pumpAndSettle();

    expect(find.text('9 pts'), findsOneWidget);
    expect(alturaDe(tester, 'ana'), lessThan(alturaDe(tester, 'beto')));
    expect(tester.widget<FilaDePuntos>(fila('ana')).lider, isTrue);
  });
}
