import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';
import 'package:brilliant/ui/widgets/dado_widget.dart';
import 'package:brilliant/ui/widgets/tablero_widget.dart';

import '../../juego/ayudantes.dart';
import '../pantallas/ayudantes_pantallas.dart';

/// Los números iniciales de la Partida 1 del manual.
const _reparto = {'C1': 4, 'F2': 1, 'B4': 2, 'E4': 5, 'C6': 3, 'E7': 6};

/// Un tope para que un ciclo infinito de pasar turno falle en vez de colgarse.
const _maximoTurnos = 300;

final _botonInicio = find.widgetWithText(FilledButton, 'Inicio');

final _finDePartida = find.byKey(const ValueKey('fin-de-partida'));

Finder _ficha(int valor) => find.byKey(ValueKey('numero-$valor'));

/// Las casillas encendidas, donde se puede anotar el dado, en el orden en que
/// se ven en el tablero.
List<String> _encendidas(WidgetTester tester) => celdasDibujadasDonde(
      tester,
      (CeldaWidget celda) => celda.iluminacion == Iluminacion.posible,
    ).toList();

/// Juega el turno [turno] tocando la pantalla, como una persona: tira, y si no
/// hay jugada pasa; si la hay, prueba el primer dado como ancla, y si no
/// enciende nada, el segundo, y anota en la primera casilla encendida.
/// Devuelve si anotó.
Future<bool> _jugarUnTurno(WidgetTester tester, int turno) async {
  await tocar(tester, botonTirar);
  if (tester.any(botonPasar)) {
    await tocar(tester, botonPasar);
    return false;
  }

  var ancla = 0;
  await tocar(tester, dadoEn(ancla));
  if (_encendidas(tester).isEmpty) {
    ancla = 1;
    await tocar(tester, dadoEn(ancla));
  }
  final encendidas = _encendidas(tester);
  expect(encendidas, isNotEmpty, reason: 'turno $turno: hay jugada, pero no se encendió nada');

  final valor = tester.widget<DadoWidget>(dadoEn(1 - ancla)).valor;
  final destino = encendidas.first;
  await tocar(tester, casillaTocable(destino));

  expect(
    celdaEn(tester, destino).celda.valor,
    valor,
    reason: 'turno $turno: en $destino tenía que quedar el $valor',
  );
  return true;
}

void main() {
  testWidgets('Camino feliz por la pantalla: se reparte, se juega la partida entera tocando y '
      'se vuelve a empezar', (tester) async {
    await abrirApp(tester, tirarDado: dadosConTodasLasCombinaciones());

    // 1. Preparación: se toca cada casilla con aro y después su número.
    expect(find.text('Prepara tu tablero'), findsOneWidget);
    expect(habilitado(tester, _botonInicio), isFalse);
    for (final MapEntry(key: casilla, value: numero) in _reparto.entries) {
      await tocar(tester, casillaTocable(casilla));
      await tocar(tester, _ficha(numero));
      expect(celdaEn(tester, casilla).celda.valor, numero);
    }
    expect(find.text('¡Listo! Toca Inicio para empezar.'), findsOneWidget);
    expect(habilitado(tester, _botonInicio), isTrue);

    // 2. Inicio lleva a la partida, con los 6 números en su lugar.
    await tocar(tester, _botonInicio);
    expect(find.text('Turno 1'), findsOneWidget);
    expect(find.text('6 de 49 casillas'), findsOneWidget);
    for (final MapEntry(key: casilla, value: numero) in _reparto.entries) {
      expect(celdaEn(tester, casilla).celda.valor, numero);
    }

    // 3. La partida entera, turno por turno, con dados sin azar que recorren
    // las 36 combinaciones.
    var colocadas = 0;
    var pasados = 0;
    while (!tester.any(_finDePartida)) {
      final turno = colocadas + pasados + 1;
      if (turno > _maximoTurnos) fail('la partida no terminó en $_maximoTurnos turnos');
      expect(find.text('Turno $turno'), findsOneWidget);

      if (await _jugarUnTurno(tester, turno)) {
        colocadas++;
        expect(find.text('${6 + colocadas} de 49 casillas'), findsOneWidget);
      } else {
        pasados++;
      }
    }

    // 4. El final: el tablero lleno, los iniciales en su lugar y ninguna zona
    // rompiendo su regla.
    expect(colocadas, 43);
    expect(find.text('Partida terminada'), findsOneWidget);
    expect(find.text('¡Tablero completo!'), findsOneWidget);
    expect(find.text('49 de 49 casillas'), findsOneWidget);
    expect(find.text('Lo jugaste en ${colocadas + pasados} turnos.'), findsOneWidget);
    expect(botonTirar, findsNothing);
    expect(celdasDibujadasDonde(tester, (CeldaWidget celda) => celda.celda.valor == null), isEmpty);
    for (final MapEntry(key: casilla, value: numero) in _reparto.entries) {
      expect(celdaEn(tester, casilla).celda.valor, numero);
    }
    expectZonasCumplenSusReglas(
      tester.widget<TableroWidget>(find.byType(TableroWidget)).tablero,
      contexto: 'camino feliz por la pantalla',
    );

    // 5. "Jugar otra vez" vuelve a una preparación vacía.
    await tocar(tester, find.widgetWithText(FilledButton, 'Jugar otra vez'));
    expect(find.text('Prepara tu tablero'), findsOneWidget);
    expect(celdasDibujadasDonde(tester, (CeldaWidget celda) => celda.celda.valor != null), isEmpty);
    expect(habilitado(tester, _botonInicio), isFalse);
  });
}
