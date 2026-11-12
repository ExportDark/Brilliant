import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

final zonasConPuestos = [
  zonaJson(
    id: 4,
    tipo: 'azul',
    color: 'azul',
    casillas: ['C1', 'C2', 'D2', 'D3'],
    puestos: [
      {'usuario': 'ana', 'puesto': 1, 'ronda': 12},
      {'usuario': 'beto', 'puesto': 2, 'ronda': 15},
    ],
    puntosSiguiente: 3,
    puntosPorPuesto: [7, 5, 3],
  ),
  zonaJson(
    id: 5,
    tipo: 'azul',
    color: 'azul',
    casillas: ['G5', 'G6', 'F6', 'F7'],
    puestos: [],
    puntosSiguiente: 7,
    puntosPorPuesto: [7, 5, 3],
  ),
  zonaJson(
    id: 10,
    tipo: 'gris',
    color: 'gris',
    casillas: ['D1', 'D7'],
    puestos: [
      {'usuario': 'ana', 'puesto': 1, 'ronda': 3},
      {'usuario': 'beto', 'puesto': 1, 'ronda': 3},
      {'usuario': 'carla', 'puesto': 3, 'ronda': 6},
    ],
    agotada: true,
    puntosSiguiente: 0,
    puntosPorPuesto: [3, 2, 1],
  ),
];

void main() {
  testWidgets('El panel de zonas dice cuáles siguen dando puntos y cuáles ya se agotaron', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'jugando',
        ronda: 3,
        dados: const [1, 3],
        segundosRestantes: 40,
        tablero: const {'E1': 1},
        zonas: zonasConPuestos,
      ),
    );

    // Una azul ya tiene sus dos primeros puestos (con quién) y el tercero libre, que paga
    // 3; la otra sigue con sus tres puestos libres; la gris se agotó.
    Finder enZona(int id, String texto) =>
        find.descendant(of: find.byKey(ValueKey('zona-$id')), matching: find.text(texto));
    expect(enZona(4, '1.º ana'), findsOneWidget);
    expect(enZona(4, '2.º beto'), findsOneWidget);
    expect(enZona(4, '3.º · 3'), findsOneWidget);
    expect(enZona(5, '1.º · 7'), findsOneWidget);
    expect(enZona(5, '2.º · 5'), findsOneWidget);
    expect(enZona(5, '3.º · 3'), findsOneWidget);
    expect(find.byKey(const ValueKey('puntos-zona-4')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const ValueKey('puntos-zona-4'))).data, 'Da 3');
    expect(tester.widget<Text>(find.byKey(const ValueKey('puntos-zona-5'))).data, 'Da 7');
    expect(tester.widget<Text>(find.byKey(const ValueKey('puntos-zona-10'))).data, 'Agotada');
    // Dos primeros: el siguiente fue el tercero.
    expect(enZona(10, '1.º ana'), findsOneWidget);
    expect(enZona(10, '1.º beto'), findsOneWidget);
    expect(enZona(10, '3.º carla'), findsOneWidget);
  });

  testWidgets('Cada zona se identifica por su color y cuántas casillas tiene', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'jugando',
        ronda: 1,
        dados: const [1, 3],
        zonas: zonasConPuestos,
      ),
    );

    expect(find.text('Azul · 4 casillas'), findsNWidgets(2));
    expect(find.text('Gris · 2 casillas'), findsOneWidget);
  });

  testWidgets('Los puntos de cada jugador se ven en la partida', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'jugando',
        ronda: 4,
        dados: const [2, 2],
        jugadores: [
          jugadorJson('ana', anfitrion: true, puntos: 10),
          jugadorJson('beto', puntos: 4),
        ],
      ),
    );

    expect(find.text('10 pts'), findsOneWidget);
    expect(find.text('4 pts'), findsOneWidget);
  });

  testWidgets('El resultado muestra el ranking con puntos, el motivo y cómo quedaron las zonas', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'terminada',
        zonas: zonasConPuestos,
        resultado: {
          'motivo': 'tablero_lleno',
          'ganadores': ['ana'],
          'ranking': [
            {'usuario': 'ana', 'estado': 'activo', 'puntos': 17, 'primeros': 2},
            {'usuario': 'beto', 'estado': 'activo', 'puntos': 12, 'primeros': 1},
            {'usuario': 'carla', 'estado': 'se_rindio', 'puntos': 4, 'primeros': 0},
          ],
        },
      ),
    );

    expect(find.text('¡Ganaste!'), findsOneWidget);
    expect(find.text('Todos llenaron su tablero.'), findsOneWidget);
    expect(find.text('ana ★'), findsOneWidget);
    expect(find.text('17 pts'), findsOneWidget);
    expect(find.text('carla (se rindió)'), findsOneWidget);
    expect(find.byKey(const ValueKey('zona-10')), findsOneWidget);
    // Los jugadores se ordenan como dice el servidor.
    final filas = tester.widgetList(find.byWidgetPredicate(
      (w) => w.key is ValueKey && (w.key as ValueKey).value.toString().startsWith('fila-'),
    )).map((w) => (w.key as ValueKey).value).toList();
    expect(filas, ['fila-ana', 'fila-beto', 'fila-carla']);
  });

  testWidgets('Si ganó otro, el resultado dice quién', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'terminada',
        resultado: {
          'motivo': 'sin_jugadas',
          'ganadores': ['beto'],
          'ranking': [
            {'usuario': 'beto', 'estado': 'activo', 'puntos': 9, 'primeros': 1},
            {'usuario': 'ana', 'estado': 'activo', 'puntos': 3, 'primeros': 0},
          ],
        },
      ),
    );

    expect(find.text('Ganó beto'), findsOneWidget);
    expect(find.text('Ya nadie puede jugar.'), findsOneWidget);
  });

  testWidgets('"Salir" del resultado vuelve a "Elige un mapa"', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(
      tester,
      salas,
      vistaDePrueba(
        estado: 'terminada',
        resultado: {'motivo': 'tablero_lleno', 'ganadores': ['ana'], 'ranking': []},
      ),
    );

    await tocar(tester, find.byKey(const ValueKey('boton-volver')));

    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
