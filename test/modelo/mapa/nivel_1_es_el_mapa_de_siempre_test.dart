import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/tablero.dart';

/// Las regiones tal como estaban escritas en `Tablero.mapaOriginal()` antes de
/// que existieran los otros mapas: número, color y casillas.
const _regionesDeAntes = [
  '1 amarillo: A1 G1 D4 A7 G7',
  '2 verde: B1 A2 B2 A3 A4 A5',
  '3 verde: G2 G3 F3 E4 F4 G4',
  '4 azul: C1 C2 D2 D3',
  '5 azul: G5 G6 F6 F7',
  '6 morado: D1 E1 F1 E2 F2 E3',
  '7 morado: C4 C5 D5 C6 C7 B7',
  '8 rojo: B3 C3 B4 B5 B6 A6',
  '9 rojo: E5 F5 E6 D6 D7 E7',
];

List<String> _regionesDe(Tablero tablero) => [
      for (final region in tablero.regiones)
        '${region.identificador} ${region.tipo.color.name}: '
            '${region.casillas.map((celda) => celda.posicion.notacion).join(' ')}',
    ];

void main() {
  test('Nivel 1: arma el mismo tablero que el mapa original de antes', () {
    final tablero = Tablero.desdeMapa(nivel1);

    expect(_regionesDe(tablero), _regionesDeAntes);
    expect(
      {for (final celda in tablero.celdas) if (celda.esInicial) celda.posicion.notacion},
      {'C1', 'F2', 'B4', 'E4', 'C6', 'E7'},
    );
    // Y mapaOriginal(), que usan muchos tests, es justamente el Nivel 1.
    expect(_regionesDe(Tablero.mapaOriginal()), _regionesDeAntes);
  });
}
