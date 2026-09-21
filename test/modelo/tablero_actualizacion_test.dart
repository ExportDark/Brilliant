import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

void main() {
  group('Tablero.conValor', () {
    test('anota el valor solo en la casilla indicada', () {
      final tablero = Tablero.mapaOriginal();
      final posicion = Posicion.desdeNotacion('C1');

      final actualizado = tablero.conValor(posicion, 4);

      expect(actualizado.celdaEn(posicion)!.valor, 4);
      expect(
        actualizado.celdas.where((celda) => !celda.estaVacia),
        hasLength(1),
      );
    });

    test('no muta el tablero original', () {
      final tablero = Tablero.mapaOriginal();
      final posicion = Posicion.desdeNotacion('C1');

      tablero.conValor(posicion, 4);

      expect(tablero.celdaEn(posicion)!.estaVacia, isTrue);
    });

    test('conserva el layout: sigue habiendo 9 regiones y 49 casillas', () {
      final actualizado = Tablero.mapaOriginal()
          .conValor(Posicion.desdeNotacion('C1'), 4)
          .conValor(Posicion.desdeNotacion('E7'), 2);

      expect(actualizado.regiones, hasLength(9));
      expect(actualizado.celdas, hasLength(49));
      expect(actualizado.celdaEn(Posicion.desdeNotacion('C1'))!.valor, 4);
      expect(actualizado.celdaEn(Posicion.desdeNotacion('E7'))!.valor, 2);
    });

    test('conserva el resto de los datos de la casilla', () {
      final posicion = Posicion.desdeNotacion('C1');
      final original = Tablero.mapaOriginal().celdaEn(posicion)!;

      final actualizada = Tablero.mapaOriginal().conValor(posicion, 4).celdaEn(posicion)!;

      expect(actualizada.color, original.color);
      expect(actualizada.esInicial, original.esInicial);
      expect(actualizada.posicion, original.posicion);
    });

    test('devuelve el mismo tablero si la posición no existe', () {
      final tablero = Tablero.mapaOriginal();

      final actualizado = tablero.conValor(const Posicion(fila: 9, columna: 9), 4);

      expect(actualizado, same(tablero));
    });
  });

  group('Tablero.sinValor', () {
    test('vacía la casilla indicada', () {
      final posicion = Posicion.desdeNotacion('F2');
      final conValor = Tablero.mapaOriginal().conValor(posicion, 5);

      final vaciado = conValor.sinValor(posicion);

      expect(vaciado.celdaEn(posicion)!.estaVacia, isTrue);
    });

    test('deja intactas las demás casillas', () {
      final tablero = Tablero.mapaOriginal()
          .conValor(Posicion.desdeNotacion('F2'), 5)
          .conValor(Posicion.desdeNotacion('B4'), 3);

      final vaciado = tablero.sinValor(Posicion.desdeNotacion('F2'));

      expect(vaciado.celdaEn(Posicion.desdeNotacion('B4'))!.valor, 3);
    });
  });
}
