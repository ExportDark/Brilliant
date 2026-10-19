import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

import 'ayudantes.dart';

/// Cada semilla es una partida distinta, pero reproducible: si una falla, se
/// puede volver a correr exactamente igual.
const _semillas = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

/// El tablero recién preparado: una permutación al azar del 1 al 6 en las
/// casillas iniciales.
Tablero _preparado(Random azar) {
  final numeros = [1, 2, 3, 4, 5, 6]..shuffle(azar);
  return Tablero.mapaOriginal().conValores({
    for (final (indice, notacion) in casillasIniciales.indexed)
      Posicion.desdeNotacion(notacion): numeros[indice],
  });
}

void main() {
  group('Partidas completas simuladas', () {
    for (final semilla in _semillas) {
      test('semilla $semilla: termina y ninguna zona rompe su regla de color', () async {
        final azar = Random(semilla);
        final bloc = PartidaBloc(_preparado(azar), tirarDado: () => azar.nextInt(6) + 1);
        addTearDown(bloc.close);

        final (:colocadas, pasados: _) =
            await jugarHastaElFinal(bloc, contexto: 'semilla $semilla');

        expect(bloc.state.terminada, isTrue);
        expect(bloc.state.casillasLlenas, casillasIniciales.length + colocadas);
        expectZonasCumplenSusReglas(bloc.state.tablero, contexto: 'semilla $semilla');
      });
    }
  });
}
