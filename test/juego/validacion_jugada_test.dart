import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

Posicion _pos(String notacion) => Posicion.desdeNotacion(notacion);

/// El tablero con los valores iniciales de la Partida 1 del manual:
/// C1=4, F2=1, B4=2, E4=5, C6=3, E7=6.
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

ResultadoJugada _evaluar(Tablero tablero, String notacion, {required int ancla, required int valor}) =>
    evaluarJugada(tablero, _pos(notacion), ancla: ancla, valor: valor);

void main() {
  group('evaluarJugada — el ancla', () {
    test('una casilla ocupada no se puede usar', () {
      expect(_evaluar(_inicial(), 'C1', ancla: 4, valor: 3), isA<CasillaOcupada>());
    });

    test('pegada a una casilla con el número ancla, vale', () {
      // B1 (verde) está a la izquierda de C1, que tiene el 4.
      expect(_evaluar(_inicial(), 'B1', ancla: 4, valor: 3), isA<JugadaValida>());
    });

    test('lejos de toda casilla con el número ancla, no vale', () {
      final resultado = _evaluar(_inicial(), 'A2', ancla: 4, valor: 3);

      expect(resultado, isA<SinAncla>());
      expect((resultado as SinAncla).ancla, 4);
    });

    test('en diagonal al ancla no cuenta', () {
      // D2 toca a C1 solo por la esquina.
      expect(_evaluar(_inicial(), 'D2', ancla: 4, valor: 3), isA<SinAncla>());
    });

    test('en el borde del tablero, las vecinas que caen fuera se ignoran', () {
      expect(_evaluar(_inicial(), 'A1', ancla: 4, valor: 1), isA<SinAncla>());
      expect(
        _evaluar(_inicial(ademas: {'B1': 4}), 'A1', ancla: 4, valor: 1),
        isA<JugadaValida>(),
      );
    });

    test('una posición fuera del tablero es un error', () {
      expect(
        () => evaluarJugada(_inicial(), const Posicion(fila: 7, columna: 0), ancla: 1, valor: 1),
        throwsArgumentError,
      );
    });
  });

  group('evaluarJugada — la regla de la zona', () {
    test('en azul solo vale el número que ya tiene la zona', () {
      final resultado = _evaluar(_inicial(), 'C2', ancla: 4, valor: 3);

      expect(resultado, isA<ReglaRota>());
      expect((resultado as ReglaRota).valoresEnZona, [4]);
      expect(_evaluar(_inicial(), 'C2', ancla: 4, valor: 4), isA<JugadaValida>());
    });

    test('en rojo no se puede repetir un número de la zona', () {
      final resultado = _evaluar(_inicial(), 'B3', ancla: 2, valor: 2);

      expect(resultado, isA<ReglaRota>());
      final rota = resultado as ReglaRota;
      expect(rota.region.identificador, 8);
      expect(rota.valoresEnZona, [2]);
      expect(_evaluar(_inicial(), 'B3', ancla: 2, valor: 3), isA<JugadaValida>());
    });

    test('en morado no entra un tercer número distinto', () {
      final tablero = _inicial(ademas: {'E1': 2});

      final resultado = _evaluar(tablero, 'E2', ancla: 1, valor: 3);

      expect(resultado, isA<ReglaRota>());
      expect((resultado as ReglaRota).valoresEnZona, unorderedEquals([1, 2]));
      expect(_evaluar(tablero, 'E2', ancla: 1, valor: 2), isA<JugadaValida>());
    });

    test('el amarillo es una sola zona aunque sus casillas estén sueltas', () {
      final tablero = _inicial(ademas: {'A1': 3, 'G6': 5});

      final resultado = _evaluar(tablero, 'G7', ancla: 5, valor: 3);

      expect(resultado, isA<ReglaRota>());
      expect((resultado as ReglaRota).region.identificador, 1);
      expect(_evaluar(tablero, 'G7', ancla: 5, valor: 4), isA<JugadaValida>());
    });
  });

  group('hayJugada', () {
    test('sin ninguna casilla con el número ancla no hay jugada', () {
      expect(hayJugada(Tablero.mapaOriginal(), ancla: 1, valor: 1), isFalse);
    });

    test('al empezar, cada ancla tiene dónde jugar', () {
      for (var ancla = 1; ancla <= 6; ancla++) {
        expect(hayJugada(_inicial(), ancla: ancla, valor: 1), isTrue);
      }
    });

    test('con una sola casilla libre, depende del ancla y de lo que acepte su zona', () {
      // E5 es la última casilla libre: su zona roja ya tiene del 1 al 5, y sus
      // vecinas tienen 1 (E4, D5, F5) y 2 (E6).
      final tablero = _llenoMenos('E5', valores: {'F5': 1, 'E6': 2, 'D6': 3, 'D7': 4, 'E7': 5});

      expect(hayJugada(tablero, ancla: 2, valor: 6), isTrue);
      expect(hayJugada(tablero, ancla: 2, valor: 3), isFalse);
      expect(hayJugada(tablero, ancla: 3, valor: 6), isFalse);
    });

    test('con el tablero lleno, no hay jugada', () {
      final tablero = _llenoMenos('E5').conValor(_pos('E5'), 1);

      for (var ancla = 1; ancla <= 6; ancla++) {
        expect(hayJugada(tablero, ancla: ancla, valor: 1), isFalse);
      }
    });
  });
}
