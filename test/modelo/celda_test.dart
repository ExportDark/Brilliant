import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/celda.dart';
import 'package:brilliant/modelo/color5.dart';

void main() {
  group('Celda', () {
    test('una celda sin valor está vacía', () {
      const celda = Celda(fila: 0, columna: 0, color: Color5.verde);

      expect(celda.estaVacia, isTrue);
      expect(celda.valor, isNull);
    });

    test('una celda con valor no está vacía', () {
      const celda = Celda(fila: 0, columna: 0, color: Color5.verde, valor: 4);

      expect(celda.estaVacia, isFalse);
      expect(celda.valor, 4);
    });

    test('esInicial es false por defecto', () {
      const celda = Celda(fila: 0, columna: 0, color: Color5.rojo);

      expect(celda.esInicial, isFalse);
    });

    test('conValor devuelve una nueva celda con el valor puesto, sin mutar la original', () {
      const original = Celda(fila: 2, columna: 3, color: Color5.azul, esInicial: true);

      final actualizada = original.conValor(5);

      expect(original.valor, isNull);
      expect(actualizada.valor, 5);
      expect(actualizada.fila, original.fila);
      expect(actualizada.columna, original.columna);
      expect(actualizada.color, original.color);
      expect(actualizada.esInicial, original.esInicial);
    });

    test('rechaza valores fuera del rango 1-6', () {
      expect(
        () => Celda(fila: 0, columna: 0, color: Color5.morado, valor: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Celda(fila: 0, columna: 0, color: Color5.morado, valor: 7),
        throwsA(isA<AssertionError>()),
      );
    });

    test('dos celdas con los mismos campos son iguales', () {
      const a = Celda(fila: 1, columna: 1, color: Color5.amarillo, valor: 2);
      const b = Celda(fila: 1, columna: 1, color: Color5.amarillo, valor: 2);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('celdas con distinto valor no son iguales', () {
      const a = Celda(fila: 1, columna: 1, color: Color5.amarillo, valor: 2);
      const b = Celda(fila: 1, columna: 1, color: Color5.amarillo, valor: 3);

      expect(a, isNot(equals(b)));
    });
  });
}
