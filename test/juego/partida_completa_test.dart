import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/extraer_valores.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

/// Cada semilla es una partida distinta, pero reproducible: si una falla, se
/// puede volver a correr exactamente igual.
const _semillas = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

/// Tope de seguridad: una partida normal dura bastante menos. Si se pasa,
/// es que el bloc se quedó pasando turnos sin terminar nunca.
const _maximoTurnos = 2000;

/// El tablero recién preparado: una permutación al azar del 1 al 6 en las
/// casillas iniciales.
Tablero _preparado(Random azar) {
  final numeros = [1, 2, 3, 4, 5, 6]..shuffle(azar);
  return Tablero.mapaOriginal().conValores({
    for (final (indice, notacion) in casillasIniciales.indexed)
      Posicion.desdeNotacion(notacion): numeros[indice],
  });
}

/// Manda [evento] y espera a que el bloc lo procese.
Future<void> _enviar(PartidaBloc bloc, PartidaEvent evento) async {
  bloc.add(evento);
  await Future<void>.delayed(Duration.zero);
}

/// Juega la partida entera haciendo siempre la primera jugada que encuentra,
/// y devuelve cuántos números anotó.
Future<int> _jugarHastaElFinal(PartidaBloc bloc, int semilla) async {
  var colocadas = 0;

  while (!bloc.state.terminada) {
    if (bloc.state.turno > _maximoTurnos) {
      fail('semilla $semilla: la partida no terminó en $_maximoTurnos turnos');
    }

    await _enviar(bloc, const DadosTirados());
    final tirada = bloc.state;
    if (tirada.sinJugada) {
      await _enviar(bloc, const TurnoPasado());
      continue;
    }

    final [primero, segundo] = tirada.dados!;
    final ancla = hayJugada(tirada.tablero, ancla: primero, valor: segundo) ? 0 : 1;
    await _enviar(bloc, DadoElegido(ancla));

    final anclado = bloc.state;
    final destino = anclado.tablero.celdas
        .map((celda) => celda.posicion)
        .firstWhere((posicion) => anclado.evaluar(posicion) is JugadaValida);
    await _enviar(bloc, ValorColocado(destino));

    expect(
      bloc.state.turno,
      anclado.turno + 1,
      reason: 'semilla $semilla: la jugada en ${destino.notacion} debió aceptarse',
    );
    colocadas++;
  }

  return colocadas;
}

/// Comprueba que cada zona cumpla su regla de color: metiendo sus valores uno
/// por uno, la regla tiene que aceptarlos todos.
void _verificarZonas(Tablero tablero, int semilla) {
  for (final region in tablero.regiones) {
    final valores = extraerValores(region);
    for (var i = 0; i < valores.length; i++) {
      expect(
        region.tipo.regla.puedeAgregar(valores.sublist(0, i), valores[i]),
        isTrue,
        reason: 'semilla $semilla: la zona #${region.identificador} '
            '(${region.tipo.color.name}) quedó con $valores',
      );
    }
  }
}

void main() {
  group('Partidas completas simuladas', () {
    for (final semilla in _semillas) {
      test('semilla $semilla: termina y ninguna zona rompe su regla de color', () async {
        final azar = Random(semilla);
        final bloc = PartidaBloc(_preparado(azar), tirarDado: () => azar.nextInt(6) + 1);
        addTearDown(bloc.close);

        final colocadas = await _jugarHastaElFinal(bloc, semilla);

        expect(bloc.state.terminada, isTrue);
        expect(bloc.state.casillasLlenas, casillasIniciales.length + colocadas);
        _verificarZonas(bloc.state.tablero, semilla);
      });
    }
  });
}
