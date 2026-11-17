import 'package:brilliant/ui/pantallas/multijugador/textos_multijugador.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo que va debajo del nombre en el marcador y el resultado. Antes iba pegado al nombre
/// ("ana (tú, se rindió)") y en un celular se cortaba con puntos suspensivos.
void main() {
  test('En mi fila, mientras sigo jugando, solo "Tú"', () {
    expect(etiquetasDeJugador(mia: true, estado: 'activo'), 'Tú');
  });

  test('Si alguien se fue, lo dice, con mayúscula al empezar', () {
    expect(etiquetasDeJugador(mia: false, estado: 'se_rindio'), 'Se rindió');
    expect(etiquetasDeJugador(mia: false, estado: 'desconectado'), 'Se desconectó');
  });

  test('Todo junto y en orden: "tú", si se fue y los primeros puestos', () {
    expect(
      etiquetasDeJugador(mia: true, estado: 'se_rindio', primeros: 1),
      'Tú, se rindió, 1 primer puesto',
    );
    expect(etiquetasDeJugador(mia: false, estado: 'activo', primeros: 3), '3 primeros puestos');
  });

  test('Sin nada que decir, no hay línea', () {
    expect(etiquetasDeJugador(mia: false, estado: 'activo'), isNull);
  });
}
