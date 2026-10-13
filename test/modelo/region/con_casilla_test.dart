import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/modelo/tipo_region.dart';

Posicion _pos(String notacion) => Posicion.desdeNotacion(notacion);

void main() {
  test('Region.conCasilla: anota solo esa casilla, conserva la región y no muta la original', () {
    // La zona azul #4: C1, C2, D2, D3.
    final original = Tablero.mapaOriginal().regionEn(_pos('C1'))!;

    final actualizada = original.conCasilla(_pos('C2'), 4);

    expect(actualizada.identificador, original.identificador);
    expect(actualizada.tipo, tipoAzul);
    expect(
      {for (final celda in actualizada.casillas) celda.posicion.notacion: celda.valor},
      {'C1': null, 'C2': 4, 'D2': null, 'D3': null},
    );
    expect(original.casillas.every((celda) => celda.estaVacia), isTrue);
  });
}
