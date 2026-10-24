import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/preparacion_bloc.dart';
import 'package:brilliant/juego/preparacion_event.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/modelo/extraer_valores.dart';
import 'package:brilliant/modelo/tablero.dart';

import '../ayudantes.dart';

/// Los números iniciales de la Partida 1 del manual.
const _reparto = {'C1': 4, 'F2': 1, 'B4': 2, 'E4': 5, 'C6': 3, 'E7': 6};

/// Revisa el tablero lleno con las reglas del manual escritas a mano, sin usar
/// las clases de reglas del código: así, si una regla del código fallara, este
/// test no la usaría para juzgarse a sí mismo.
void _expectReglasDelManual(Tablero tablero) {
  for (final region in tablero.regiones) {
    final valores = extraerValores(region);
    final distintos = valores.toSet();
    final zona = 'la zona #${region.identificador} (${region.tipo.color.name}) con $valores';

    switch (region.tipo.color) {
      case ColorZona.rojo:
        expect(distintos, {1, 2, 3, 4, 5, 6}, reason: '$zona: tiene que ser una corrida del 1 al 6');
      case ColorZona.amarillo:
        expect(distintos, hasLength(valores.length), reason: '$zona: no puede repetir');
      case ColorZona.azul:
        expect(distintos, hasLength(1), reason: '$zona: todos iguales');
      case ColorZona.morado:
        expect(distintos.length, lessThanOrEqualTo(2), reason: '$zona: dos números como máximo');
      case ColorZona.verde:
        break;
    }
  }
}

void main() {
  test('Camino feliz: una partida bien jugada, de la preparación al final, llena el tablero '
      'sin romper ninguna regla', () async {
    // 1. Preparación: se reparten los 6 números y se confirma.
    final preparacion = PreparacionBloc(casillasIniciales.map(pos).toList());
    addTearDown(preparacion.close);
    for (final MapEntry(key: casilla, value: numero) in _reparto.entries) {
      preparacion.add(ValorAsignado(pos(casilla), numero));
    }
    preparacion.add(const PreparacionConfirmada());
    await Future<void>.delayed(Duration.zero);

    expect(preparacion.state.completa, isTrue);
    expect(preparacion.state.confirmada, isTrue);

    // 2. El paso a la partida: el tablero se arma igual que al oprimir Inicio.
    final tablero = Tablero.mapaOriginal().conValores(preparacion.state.valores);

    expect(
      {for (final casilla in _reparto.keys) casilla: tablero.celdaEn(pos(casilla))!.valor},
      _reparto,
    );
    expect(tablero.celdas.where((celda) => celda.estaVacia), hasLength(43));

    // 3. La partida, con dados sin azar que recorren las 36 combinaciones.
    final partida = PartidaBloc(tablero, tirarDado: dadosConTodasLasCombinaciones());
    addTearDown(partida.close);

    final (:colocadas, :pasados) = await jugarHastaElFinal(partida, contexto: 'camino feliz');

    // 4. El final: el tablero lleno, los iniciales en su lugar y todas las
    // zonas cumpliendo su regla.
    final finalDePartida = partida.state;
    expect(finalDePartida.terminada, isTrue);
    expect(colocadas, 43);
    expect(finalDePartida.casillasLlenas, 49);
    expect(finalDePartida.turno, 1 + colocadas + pasados);
    for (final MapEntry(key: casilla, value: numero) in _reparto.entries) {
      expect(finalDePartida.tablero.celdaEn(pos(casilla))!.valor, numero);
    }
    _expectReglasDelManual(finalDePartida.tablero);
  });
}
