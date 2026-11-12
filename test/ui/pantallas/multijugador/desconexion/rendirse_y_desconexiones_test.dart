import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/multijugador/modelos.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

final botonRendirse = find.byKey(const ValueKey('boton-rendirse'));
final confirmarRendirse = find.byKey(const ValueKey('confirmar-rendirse'));

Future<SalasFalsas> _enPartida(WidgetTester tester, {VistaDeSala? vista}) async {
  final salas = SalasFalsas();
  await abrirMultijugador(tester, salas);
  await crearSala(tester, salas, vista ?? partidaEnJuego());
  return salas;
}

Map<String, dynamic> _resultado(String motivo, List<String> ganadores, {List<Map<String, dynamic>>? ranking}) => {
      'motivo': motivo,
      'ganadores': ganadores,
      'ranking': ranking ??
          [
            {'usuario': 'ana', 'estado': 'activo', 'puntos': 0, 'primeros': 0},
            {'usuario': 'beto', 'estado': 'activo', 'puntos': 0, 'primeros': 0},
          ],
    };

void main() {
  group('Rendirse', () {
    testWidgets('pide confirmación, y "Seguir jugando" no hace nada', (tester) async {
      final salas = await _enPartida(tester);

      await tocar(tester, botonRendirse);
      expect(find.text('¿Rendirte?'), findsOneWidget);
      await tocar(tester, find.text('Seguir jugando'));

      expect(salas.llamadas, isNot(contains('rendirse')));
      expect(find.byKey(const ValueKey('ronda-y-tiempo')), findsOneWidget);
    });

    testWidgets('confirmar manda rendirse y muestra el resultado', (tester) async {
      final salas = await _enPartida(tester);
      salas.alRendirse = vistaDePrueba(
        version: 8,
        estado: 'terminada',
        miEstado: 'se_rindio',
        resultado: _resultado('ultimo_jugador', ['beto'], ranking: [
          {'usuario': 'beto', 'estado': 'activo', 'puntos': 0, 'primeros': 0},
          {'usuario': 'ana', 'estado': 'se_rindio', 'puntos': 0, 'primeros': 0},
        ]),
      );

      await tocar(tester, botonRendirse);
      await tocar(tester, confirmarRendirse);

      expect(salas.llamadas, contains('rendirse'));
      expect(find.byKey(const ValueKey('resultado')), findsOneWidget);
      expect(find.text('Ganó beto'), findsOneWidget);
    });

    testWidgets('quien ya se rindió ya no ve el botón', (tester) async {
      await _enPartida(
        tester,
        vista: vistaDePrueba(
          estado: 'jugando',
          ronda: 3,
          dados: const [2, 2],
          miEstado: 'se_rindio',
        ),
      );

      expect(botonRendirse, findsNothing);
      expect(find.text('Quedaste fuera de la partida.'), findsOneWidget);
    });

    testWidgets('salir del lobby manda rendirse y vuelve directo a "Elige un mapa"', (
      tester,
    ) async {
      final salas = SalasFalsas();
      await abrirMultijugador(tester, salas);
      await crearSala(tester, salas, vistaDePrueba());
      salas.alRendirse = null;

      await tocar(tester, find.byKey(const ValueKey('boton-salir')));

      expect(salas.llamadas, contains('rendirse'));
      expect(find.byKey(const ValueKey('fin-de-la-sala')), findsNothing);
      expect(find.text('Elige un mapa'), findsOneWidget);
    });
  });

  group('Cuando otro jugador se va', () {
    testWidgets('se ve que se desconectó y la partida sigue', (tester) async {
      final salas = await _enPartida(tester);

      salas.vista = vistaDePrueba(
        version: 9,
        estado: 'jugando',
        ronda: 2,
        dados: const [2, 5],
        segundosRestantes: 55,
        tablero: const {'E1': 1},
        jugadores: [
          jugadorJson('ana', anfitrion: true),
          jugadorJson('beto', estado: 'desconectado'),
        ],
      );
      await pasarSegundos(tester, 1);

      expect(find.text('beto (se desconectó)'), findsOneWidget);
      expect(find.text('Ronda 2 · 55 s'), findsOneWidget);
      expect(find.byKey(const ValueKey('resultado')), findsNothing);
    });

    testWidgets('con dos jugadores, si el otro se va gano yo', (tester) async {
      final salas = await _enPartida(tester);

      salas.vista = vistaDePrueba(
        version: 9,
        estado: 'terminada',
        resultado: _resultado('ultimo_jugador', ['ana'], ranking: [
          {'usuario': 'ana', 'estado': 'activo', 'puntos': 3, 'primeros': 1},
          {'usuario': 'beto', 'estado': 'desconectado', 'puntos': 0, 'primeros': 0},
        ]),
      );
      await pasarSegundos(tester, 1);

      expect(find.text('¡Ganaste!'), findsOneWidget);
      expect(find.text('Los demás salieron: gana el último que quedó.'), findsOneWidget);
    });

    testWidgets('si se va el anfitrión, ganan los demás', (tester) async {
      final salas = SalasFalsas()..vista = vistaDePrueba(yo: 'beto', anfitrion: 'ana');
      await abrirMultijugador(tester, salas);
      await tester.enterText(campoCodigo, 'K7M4QX');
      await tocar(tester, botonUnirse);

      salas.vista = vistaDePrueba(
        version: 9,
        estado: 'terminada',
        yo: 'beto',
        anfitrion: 'ana',
        resultado: _resultado('anfitrion_se_fue', ['beto', 'carla'], ranking: [
          {'usuario': 'beto', 'estado': 'activo', 'puntos': 0, 'primeros': 0},
          {'usuario': 'carla', 'estado': 'activo', 'puntos': 0, 'primeros': 0},
          {'usuario': 'ana', 'estado': 'desconectado', 'puntos': 0, 'primeros': 0},
        ]),
      );
      await pasarSegundos(tester, 1);

      expect(find.text('¡Empataste y ganaste!'), findsOneWidget);
      expect(find.text('El anfitrión se fue: ganan los demás.'), findsOneWidget);
    });

    testWidgets('si se desconectan todos, nadie gana', (tester) async {
      final salas = await _enPartida(tester);

      salas.vista = vistaDePrueba(
        version: 9,
        estado: 'terminada',
        resultado: _resultado('todos_se_fueron', []),
      );
      await pasarSegundos(tester, 1);

      expect(find.text('Nadie ganó'), findsOneWidget);
      expect(find.text('Todos salieron: nadie gana.'), findsOneWidget);
    });
  });

  group('Cuando yo me quedo sin conexión', () {
    testWidgets('al volver la conexión veo que el servidor ya me había sacado', (tester) async {
      final salas = await _enPartida(tester);

      salas.vista = vistaDePrueba(
        version: 12,
        estado: 'jugando',
        ronda: 5,
        dados: const [4, 4],
        segundosRestantes: 20,
        miEstado: 'desconectado',
        tablero: const {'E1': 1},
      );
      await pasarSegundos(tester, 1);

      expect(find.text('Quedaste fuera de la partida.'), findsOneWidget);
      expect(botonRendirse, findsNothing);
      // Ya no tengo nada que tocar.
      expect(casillaTocable('D1'), findsNothing);
    });
  });
}
