import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

Posicion _pos(String notacion) => Posicion.desdeNotacion(notacion);

void main() {
  test('Region.sinCasilla: vacía solo esa casilla y deja las demás como estaban', () {
    // La zona azul #4 con un 4 en C1 y otro en C2.
    final llena = Tablero.mapaOriginal()
        .regionEn(_pos('C1'))!
        .conCasilla(_pos('C1'), 4)
        .conCasilla(_pos('C2'), 4);

    final vaciada = llena.sinCasilla(_pos('C2'));

    expect(
      {for (final celda in vaciada.casillas) celda.posicion.notacion: celda.valor},
      {'C1': 4, 'C2': null, 'D2': null, 'D3': null},
    );
    expect(llena.casillas.firstWhere((celda) => celda.posicion == _pos('C2')).valor, 4);
  });
}
