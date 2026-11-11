import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/multijugador/modelos.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';
import 'package:brilliant/ui/widgets/dado_widget.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

/// Entra a una partida ya en juego, en la ronda 1 con los dados (1, 3).
Future<SalasFalsas> _enPartida(WidgetTester tester, {VistaDeSala? vista}) async {
  final salas = SalasFalsas();
  await abrirMultijugador(tester, salas);
  await crearSala(tester, salas, vista ?? partidaEnJuego());
  return salas;
}

final dado0 = find.byKey(const ValueKey('dado-0'));
final dado1 = find.byKey(const ValueKey('dado-1'));
final indicacion = find.byKey(const ValueKey('indicacion'));

Iluminacion _iluminacion(WidgetTester tester, String notacion) =>
    celdaEn(tester, notacion).iluminacion;

void main() {
  testWidgets('La partida muestra la ronda, los dos dados y mi tablero', (tester) async {
    await _enPartida(tester);

    expect(find.text('Ronda 1 · 60 s'), findsOneWidget);
    expect(tester.widget<DadoWidget>(dado0).valor, 1);
    expect(tester.widget<DadoWidget>(dado1).valor, 3);
    // Mi tablero, con mis 6 números iniciales y nada más.
    final conNumero = celdasDibujadasDonde(tester, (c) => c.celda.valor != null);
    expect(conNumero, {'E1', 'A3', 'C4', 'F5', 'B6', 'E7'});
  });

  testWidgets('Sin elegir dado ancla, nada está iluminado y se pide elegir uno', (tester) async {
    await _enPartida(tester);

    expect(find.text('Toca un dado: es el ancla, el número que se busca en tu tablero.'), findsOneWidget);
    expect(celdasDibujadasDonde(tester, (c) => c.iluminacion == Iluminacion.posible), isEmpty);
  });

  testWidgets('Al elegir el dado ancla se iluminan las casillas donde se puede anotar el otro', (
    tester,
  ) async {
    await _enPartida(tester);

    await tocar(tester, dado0); // el ancla es el 1; el otro dado, un 3

    expect(find.text('Anota el 3 en una casilla iluminada.'), findsOneWidget);
    expect(
      celdasDibujadasDonde(tester, (c) => c.iluminacion == Iluminacion.posible),
      {'D1', 'E2', 'F1'},
    );
    expect(tester.widget<DadoWidget>(dado0).anclado, isTrue);
    expect(tester.widget<DadoWidget>(dado1).anclado, isFalse);
  });

  testWidgets('Cambiar de dado ancla cambia lo iluminado', (tester) async {
    await _enPartida(tester);
    await tocar(tester, dado0);

    await tocar(tester, dado1); // ahora el ancla es el 3; el otro dado, un 1

    expect(find.text('Anota el 1 en una casilla iluminada.'), findsOneWidget);
    expect(
      celdasDibujadasDonde(tester, (c) => c.iluminacion == Iluminacion.posible),
      {'A2', 'A4', 'B3'},
    );
  });

  testWidgets('Tocar una casilla iluminada manda la jugada con la ronda y el dado ancla', (
    tester,
  ) async {
    final salas = await _enPartida(tester);
    await tocar(tester, dado0);
    salas.vista = partidaEnJuego(
      version: 6,
      accion: 'coloco',
      tablero: const {'E1': 1, 'A3': 3, 'C4': 4, 'F5': 5, 'B6': 6, 'E7': 2, 'D1': 3},
    );

    await tocar(tester, casillaTocable('D1'));

    expect(salas.llamadas, contains('jugar 1 1 D1'));
    expect(find.text('Anotaste. Esperando a los demás…'), findsOneWidget);
    expect(celdaEn(tester, 'D1').celda.valor, 3);
  });

  testWidgets('Una casilla que no está iluminada no responde al toque', (tester) async {
    final salas = await _enPartida(tester);
    await tocar(tester, dado0);

    expect(casillaTocable('G7'), findsNothing);
    expect(casillaTocable('D1'), findsOneWidget);
    expect(salas.llamadas.where((l) => l.startsWith('jugar')), isEmpty);
  });

  testWidgets('Si solo hay un dado con jugadas, ya viene elegido', (tester) async {
    await _enPartida(
      tester,
      vista: partidaEnJuego(jugadas: const [
        {'ancla': 1, 'valor': 3, 'casillas': ['D1']},
        {'ancla': 3, 'valor': 1, 'casillas': <String>[]},
      ]),
    );

    expect(find.text('Anota el 3 en una casilla iluminada.'), findsOneWidget);
    expect(_iluminacion(tester, 'D1'), Iluminacion.posible);
  });

  testWidgets('El dado sin jugadas no se puede elegir como ancla', (tester) async {
    await _enPartida(
      tester,
      vista: partidaEnJuego(jugadas: const [
        {'ancla': 1, 'valor': 3, 'casillas': ['D1']},
        {'ancla': 3, 'valor': 1, 'casillas': <String>[]},
      ]),
    );

    expect(tester.widget<DadoWidget>(dado1).alTocar, isNull);
  });

  testWidgets('Una jugada que el servidor rechaza muestra por qué, y se puede intentar otra', (
    tester,
  ) async {
    final salas = await _enPartida(tester);
    await tocar(tester, dado0);
    salas.errorEnElProximo = const ErrorDeSala(
      codigo: 'jugada_invalida',
      mensaje: 'Ahí no se puede anotar.',
      estadoHttp: 400,
      motivo: 'regla_rota',
    );

    await tocar(tester, casillaTocable('D1'));

    expect(find.text('La regla de esa zona no permite ese número.'), findsOneWidget);
    expect(casillaTocable('E2'), findsOneWidget, reason: 'el turno no se gastó');
  });

  testWidgets('Un doble toque no muestra ningún error', (tester) async {
    final salas = await _enPartida(tester);
    await tocar(tester, dado0);
    salas.errorEnElProximo = const ErrorDeSala(
      codigo: 'ya_jugaste',
      mensaje: 'Ya jugaste esta ronda.',
      estadoHttp: 409,
    );

    await tocar(tester, casillaTocable('D1'));

    expect(errorDeSala, findsNothing);
  });

  testWidgets('Cuando llega la ronda siguiente se olvida el dado ancla que se había elegido', (
    tester,
  ) async {
    final salas = await _enPartida(tester);
    await tocar(tester, dado0);

    salas.vista = vistaDePrueba(
      version: 9,
      estado: 'jugando',
      ronda: 2,
      dados: const [2, 5],
      segundosRestantes: 60,
      tablero: const {'E1': 1, 'E7': 2},
      jugadas: const [
        {'ancla': 2, 'valor': 5, 'casillas': ['D7', 'F7']},
        {'ancla': 5, 'valor': 2, 'casillas': ['F4', 'F6']},
      ],
    );
    await pasarSegundos(tester, 1);

    expect(find.text('Ronda 2 · 60 s'), findsOneWidget);
    expect(find.text('Toca un dado: es el ancla, el número que se busca en tu tablero.'), findsOneWidget);
    expect(celdasDibujadasDonde(tester, (c) => c.iluminacion == Iluminacion.posible), isEmpty);
  });
}
