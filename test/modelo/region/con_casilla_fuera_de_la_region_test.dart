import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

Posicion _pos(String notacion) => Posicion.desdeNotacion(notacion);

void main() {
  test('Region.conCasilla: una casilla que no es de la región no cambia nada', () {
    // A1 es amarilla: no pertenece a la zona azul #4.
    final azul = Tablero.mapaOriginal().regionEn(_pos('C1'))!;

    final igual = azul.conCasilla(_pos('A1'), 5);

    expect(igual.casillas, azul.casillas);
  });
}
