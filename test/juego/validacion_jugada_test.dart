import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

import 'ayudantes.dart';

// El orden de los chequeos (qué resultado gana cuando fallan dos cosas) vive
// uno por archivo en `validacion/`.

void main() {
  group('evaluarJugada — el ancla', () {
    test('una casilla ocupada no se puede usar', () {
      expect(evaluarEn(tableroPartida1(), 'C1', ancla: 4, valor: 3), isA<CasillaOcupada>());
    });

    test('pegada a una casilla con el número ancla, vale', () {
      // B1 (verde) está a la izquierda de C1, que tiene el 4.
      expect(evaluarEn(tableroPartida1(), 'B1', ancla: 4, valor: 3), isA<JugadaValida>());
    });

    test('lejos de toda casilla con el número ancla, no vale', () {
      final resultado = evaluarEn(tableroPartida1(), 'A2', ancla: 4, valor: 3);

      expect(resultado, isA<SinAncla>());
      expect((resultado as SinAncla).ancla, 4);
    });

    test('en diagonal al ancla no cuenta', () {
      // D2 toca a C1 solo por la esquina.
      expect(evaluarEn(tableroPartida1(), 'D2', ancla: 4, valor: 3), isA<SinAncla>());
    });

    test('en el borde del tablero, las vecinas que caen fuera se ignoran', () {
      expect(evaluarEn(tableroPartida1(), 'A1', ancla: 4, valor: 1), isA<SinAncla>());
      expect(
        evaluarEn(tableroPartida1(ademas: {'B1': 4}), 'A1', ancla: 4, valor: 1),
        isA<JugadaValida>(),
      );
    });

    test('una posición fuera del tablero es un error', () {
      expect(
        () => evaluarJugada(tableroPartida1(), const Posicion(fila: 7, columna: 0), ancla: 1, valor: 1),
        throwsArgumentError,
      );
    });
  });

  group('evaluarJugada — la regla de la zona', () {
    test('en azul solo vale el número que ya tiene la zona', () {
      final resultado = evaluarEn(tableroPartida1(), 'C2', ancla: 4, valor: 3);

      expect(resultado, isA<ReglaRota>());
      expect((resultado as ReglaRota).valoresEnZona, [4]);
      expect(evaluarEn(tableroPartida1(), 'C2', ancla: 4, valor: 4), isA<JugadaValida>());
    });

    test('en rojo no se puede repetir un número de la zona', () {
      final resultado = evaluarEn(tableroPartida1(), 'B3', ancla: 2, valor: 2);

      expect(resultado, isA<ReglaRota>());
      final rota = resultado as ReglaRota;
      expect(rota.region.identificador, 8);
      expect(rota.valoresEnZona, [2]);
      expect(evaluarEn(tableroPartida1(), 'B3', ancla: 2, valor: 3), isA<JugadaValida>());
    });

    test('en morado no entra un tercer número distinto', () {
      final tablero = tableroPartida1(ademas: {'E1': 2});

      final resultado = evaluarEn(tablero, 'E2', ancla: 1, valor: 3);

      expect(resultado, isA<ReglaRota>());
      expect((resultado as ReglaRota).valoresEnZona, unorderedEquals([1, 2]));
      expect(evaluarEn(tablero, 'E2', ancla: 1, valor: 2), isA<JugadaValida>());
    });

    test('el amarillo es una sola zona aunque sus casillas estén sueltas', () {
      final tablero = tableroPartida1(ademas: {'A1': 3, 'G6': 5});

      final resultado = evaluarEn(tablero, 'G7', ancla: 5, valor: 3);

      expect(resultado, isA<ReglaRota>());
      expect((resultado as ReglaRota).region.identificador, 1);
      expect(evaluarEn(tablero, 'G7', ancla: 5, valor: 4), isA<JugadaValida>());
    });
  });

  group('hayJugada', () {
    test('sin ninguna casilla con el número ancla no hay jugada', () {
      expect(hayJugada(Tablero.mapaOriginal(), ancla: 1, valor: 1), isFalse);
    });

    test('al empezar, cada ancla tiene dónde jugar', () {
      for (var ancla = 1; ancla <= 6; ancla++) {
        expect(hayJugada(tableroPartida1(), ancla: ancla, valor: 1), isTrue);
      }
    });

    test('con una sola casilla libre, depende del ancla y de lo que acepte su zona', () {
      // E5 es la última casilla libre: su zona roja ya tiene del 1 al 5, y sus
      // vecinas tienen 1 (E4, D5, F5) y 2 (E6).
      final tablero = llenoMenos('E5', valores: {'F5': 1, 'E6': 2, 'D6': 3, 'D7': 4, 'E7': 5});

      expect(hayJugada(tablero, ancla: 2, valor: 6), isTrue);
      expect(hayJugada(tablero, ancla: 2, valor: 3), isFalse);
      expect(hayJugada(tablero, ancla: 3, valor: 6), isFalse);
    });

    test('con el tablero lleno, no hay jugada', () {
      final tablero = llenoMenos('E5').conValor(pos('E5'), 1);

      for (var ancla = 1; ancla <= 6; ancla++) {
        expect(hayJugada(tablero, ancla: ancla, valor: 1), isFalse);
      }
    });
  });
}
