import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/celda.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/modelo/posicion.dart';

void main() {
  test('Celda.sinValor: vacía la casilla y conserva posición, color y si es inicial', () {
    const llena = Celda(
      posicion: Posicion(fila: 0, columna: 2),
      color: ColorZona.azul,
      valor: 4,
      esInicial: true,
    );

    final vacia = llena.sinValor();

    expect(vacia.estaVacia, isTrue);
    expect(vacia.posicion, llena.posicion);
    expect(vacia.color, ColorZona.azul);
    expect(vacia.esInicial, isTrue);
    expect(llena.valor, 4);
  });
}
