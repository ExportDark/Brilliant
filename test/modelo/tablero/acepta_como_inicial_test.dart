import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

List<int> _aceptados(Tablero tablero, String notacion) => [
      for (var valor = 1; valor <= 6; valor++)
        if (tablero.aceptaComoInicial(Posicion.desdeNotacion(notacion), valor)) valor,
    ];

void main() {
  test('Tablero.aceptaComoInicial: en el Nivel 4, las iniciales naranjas solo aceptan su rango', () {
    final tablero = Tablero.desdeMapa(nivel4);

    expect(_aceptados(tablero, 'E1'), [4, 5, 6], reason: 'E1 está en la fila "4-6"');
    expect(_aceptados(tablero, 'B7'), [1, 2, 3], reason: 'B7 está en la fila "1-3"');
    // Las demás iniciales aceptan cualquiera: su zona empieza vacía.
    for (final casilla in ['C3', 'F3', 'A4', 'E6']) {
      expect(_aceptados(tablero, casilla), [1, 2, 3, 4, 5, 6], reason: casilla);
    }
  });

  test('Tablero.aceptaComoInicial: en los otros mapas, toda inicial acepta cualquier número', () {
    for (final mapa in [nivel1, nivel2, nivel3]) {
      final tablero = Tablero.desdeMapa(mapa);
      for (final casilla in mapa.casillasIniciales) {
        expect(
          _aceptados(tablero, casilla),
          [1, 2, 3, 4, 5, 6],
          reason: '${mapa.nombre}, $casilla',
        );
      }
    }
  });
}
