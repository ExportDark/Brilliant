import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

Posicion _pos(String notacion) => Posicion.desdeNotacion(notacion);

/// El tablero con los valores iniciales de la Partida 1 del manual.
Tablero _inicial({Map<String, int> ademas = const {}}) {
  final valores = {'C1': 4, 'F2': 1, 'B4': 2, 'E4': 5, 'C6': 3, 'E7': 6, ...ademas};
  return Tablero.mapaOriginal().conValores({
    for (final MapEntry(key: notacion, value: valor) in valores.entries) _pos(notacion): valor,
  });
}

/// Todo el tablero lleno menos [libre]. Las casillas sin valor en [valores]
/// llevan un 1; no se revisan las reglas al llenarlo.
Tablero _llenoMenos(String libre, {Map<String, int> valores = const {}}) {
  final base = Tablero.mapaOriginal();
  return base.conValores({
    for (final celda in base.celdas)
      if (celda.posicion != _pos(libre)) celda.posicion: valores[celda.posicion.notacion] ?? 1,
  });
}

ResultadoJugada _evaluar(Tablero tablero, String notacion, int valor) =>
    evaluarJugada(tablero, _pos(notacion), valor);

void main() {
  group('evaluarJugada', () {
    test('una casilla inicial ya está ocupada', () {
      expect(_evaluar(_inicial(), 'C1', 4), isA<CasillaOcupada>());
    });

    test('en verde cualquier número vale', () {
      for (var valor = 1; valor <= 6; valor++) {
        expect(_evaluar(_inicial(), 'A2', valor), isA<JugadaValida>());
      }
    });

    test('en rojo no se puede repetir un número de la zona', () {
      final resultado = _evaluar(_inicial(), 'B3', 2);

      expect(resultado, isA<ReglaRota>());
      final rota = resultado as ReglaRota;
      expect(rota.region.identificador, 8);
      expect(rota.valoresEnZona, [2]);
      expect(_evaluar(_inicial(), 'B3', 3), isA<JugadaValida>());
    });

    test('en azul solo vale el número que ya tiene la zona', () {
      final resultado = _evaluar(_inicial(), 'C2', 3);

      expect(resultado, isA<ReglaRota>());
      expect((resultado as ReglaRota).valoresEnZona, [4]);
      expect(_evaluar(_inicial(), 'C2', 4), isA<JugadaValida>());
    });

    test('en morado no entra un tercer número distinto', () {
      final tablero = _inicial(ademas: {'E1': 2});

      final resultado = _evaluar(tablero, 'E3', 3);

      expect(resultado, isA<ReglaRota>());
      expect((resultado as ReglaRota).valoresEnZona, unorderedEquals([1, 2]));
      expect(_evaluar(tablero, 'E3', 1), isA<JugadaValida>());
      expect(_evaluar(tablero, 'E3', 2), isA<JugadaValida>());
    });

    test('el amarillo es una sola zona aunque sus casillas estén sueltas', () {
      final tablero = _inicial(ademas: {'A1': 3});

      final resultado = _evaluar(tablero, 'G7', 3);

      expect(resultado, isA<ReglaRota>());
      expect((resultado as ReglaRota).region.identificador, 1);
      expect(_evaluar(tablero, 'G7', 4), isA<JugadaValida>());
    });

    test('una posición fuera del tablero es un error', () {
      expect(
        () => evaluarJugada(_inicial(), const Posicion(fila: 7, columna: 0), 1),
        throwsArgumentError,
      );
    });
  });

  group('hayLugarPara', () {
    test('al empezar, todos los números tienen lugar', () {
      for (var valor = 1; valor <= 6; valor++) {
        expect(hayLugarPara(_inicial(), valor), isTrue);
      }
    });

    test('con una sola casilla libre, solo cabe lo que acepta su zona', () {
      // E5 es la última casilla de la zona roja #9, que ya tiene del 1 al 5.
      final tablero = _llenoMenos('E5', valores: {'F5': 1, 'E6': 2, 'D6': 3, 'D7': 4, 'E7': 5});

      expect(hayLugarPara(tablero, 6), isTrue);
      expect(hayLugarPara(tablero, 2), isFalse);
    });

    test('con el tablero lleno, nada tiene lugar', () {
      final tablero = _llenoMenos('E5').conValor(_pos('E5'), 1);

      for (var valor = 1; valor <= 6; valor++) {
        expect(hayLugarPara(tablero, valor), isFalse);
      }
    });
  });
}
