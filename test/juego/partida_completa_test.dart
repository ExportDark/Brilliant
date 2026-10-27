import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

import 'ayudantes.dart';

/// Cada semilla es una partida distinta, pero reproducible: si una falla, se
/// puede volver a correr exactamente igual.
const _semillas = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

/// El tablero de [mapa] recién preparado: una permutación al azar del 1 al 6
/// en sus casillas iniciales, en la que cada número cabe en su casilla (en el
/// Nivel 4, dos iniciales están en zonas naranjas).
Tablero _preparado(Mapa mapa, Random azar) {
  final vacio = Tablero.desdeMapa(mapa);
  final casillas = mapa.casillasIniciales.map(Posicion.desdeNotacion).toList();
  final numeros = [1, 2, 3, 4, 5, 6];
  do {
    numeros.shuffle(azar);
  } while (!casillas.indexed.every((par) => vacio.aceptaComoInicial(par.$2, numeros[par.$1])));
  return vacio.conValores({
    for (final (indice, casilla) in casillas.indexed) casilla: numeros[indice],
  });
}

void main() {
  for (final mapa in mapas) {
    group('Partidas completas simuladas, ${mapa.nombre}', () {
      for (final semilla in _semillas) {
        test('semilla $semilla: termina y ninguna zona rompe su regla de color', () async {
          final contexto = '${mapa.nombre}, semilla $semilla';
          final azar = Random(semilla);
          final bloc = PartidaBloc(_preparado(mapa, azar), tirarDado: () => azar.nextInt(6) + 1);
          addTearDown(bloc.close);

          final (:colocadas, pasados: _) = await jugarHastaElFinal(bloc, contexto: contexto);

          expect(bloc.state.terminada, isTrue);
          expect(bloc.state.casillasLlenas, mapa.casillasIniciales.length + colocadas);
          expectZonasCumplenSusReglas(bloc.state.tablero, contexto: contexto);
        });
      }
    });
  }
}
