import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/preparacion_bloc.dart';
import 'package:brilliant/juego/preparacion_event.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/modelo/extraer_valores.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/modelo/tipo_region.dart';

import '../ayudantes.dart';

/// Los números que se reparten, en el orden de las casillas iniciales de
/// cada mapa: los de la Partida 1 del manual.
const _numeros = [4, 1, 2, 5, 3, 6];

/// Revisa el tablero lleno con las reglas de las tarjetas escritas a mano,
/// sin usar las clases de reglas del código: así, si una regla del código
/// fallara, este test no la usaría para juzgarse a sí mismo.
void _expectReglasDelManual(Tablero tablero) {
  for (final region in tablero.regiones) {
    final valores = extraerValores(region);
    final distintos = valores.toSet();
    final zona = 'la zona #${region.identificador} (${region.tipo.color.name}) con $valores';

    switch (region.tipo.color) {
      case ColorZona.rojo:
      case ColorZona.amarillo:
        expect(distintos, hasLength(valores.length), reason: '$zona: no puede repetir');
      case ColorZona.azul:
      case ColorZona.gris:
        expect(distintos, hasLength(1), reason: '$zona: todos iguales');
      case ColorZona.morado:
        expect(distintos.length, lessThanOrEqualTo(2), reason: '$zona: dos números como máximo');
      case ColorZona.naranja:
        final rango = region.tipo == tipoNaranjaBajo ? {1, 2, 3} : {4, 5, 6};
        expect(rango.containsAll(distintos), isTrue, reason: '$zona: solo números de $rango');
      case ColorZona.verde:
        break;
    }
  }
}

void main() {
  for (final mapa in mapas) {
    test('Camino feliz, ${mapa.nombre}: una partida bien jugada, de la preparación al final, '
        'llena el tablero sin romper ninguna regla', () async {
      final reparto = {
        for (final (indice, casilla) in mapa.casillasIniciales.indexed) casilla: _numeros[indice],
      };

      // 1. Preparación: se reparten los 6 números y se confirma.
      final preparacion = PreparacionBloc(mapa.casillasIniciales.map(pos).toList());
      addTearDown(preparacion.close);
      for (final MapEntry(key: casilla, value: numero) in reparto.entries) {
        preparacion.add(ValorAsignado(pos(casilla), numero));
      }
      preparacion.add(const PreparacionConfirmada());
      await Future<void>.delayed(Duration.zero);

      expect(preparacion.state.completa, isTrue);
      expect(preparacion.state.confirmada, isTrue);

      // 2. El paso a la partida: el tablero se arma igual que al oprimir Inicio.
      final tablero = Tablero.desdeMapa(mapa).conValores(preparacion.state.valores);

      expect(
        {for (final casilla in reparto.keys) casilla: tablero.celdaEn(pos(casilla))!.valor},
        reparto,
      );
      expect(tablero.celdas.where((celda) => celda.estaVacia), hasLength(43));

      // 3. La partida, con dados sin azar que recorren las 36 combinaciones.
      final partida = PartidaBloc(tablero, tirarDado: dadosConTodasLasCombinaciones());
      addTearDown(partida.close);

      final (:colocadas, :pasados) =
          await jugarHastaElFinal(partida, contexto: 'camino feliz, ${mapa.nombre}');

      // 4. El final: el tablero lleno, los iniciales en su lugar y todas las
      // zonas cumpliendo su regla.
      final finalDePartida = partida.state;
      expect(finalDePartida.terminada, isTrue);
      expect(colocadas, 43);
      expect(finalDePartida.casillasLlenas, 49);
      expect(finalDePartida.turno, 1 + colocadas + pasados);
      for (final MapEntry(key: casilla, value: numero) in reparto.entries) {
        expect(finalDePartida.tablero.celdaEn(pos(casilla))!.valor, numero);
      }
      _expectReglasDelManual(finalDePartida.tablero);
    });
  }
}
