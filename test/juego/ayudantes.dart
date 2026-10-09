// Ayudantes compartidos por los tests de `juego/`. No termina en `_test.dart`,
// así que `flutter test` no lo corre: solo lo importan los tests.

import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';

Posicion pos(String notacion) => Posicion.desdeNotacion(notacion);

/// El tablero con los valores iniciales de la Partida 1 del manual
/// (C1=4, F2=1, B4=2, E4=5, C6=3, E7=6), más lo que traiga [ademas].
Tablero tableroPartida1({Map<String, int> ademas = const {}}) {
  final valores = {'C1': 4, 'F2': 1, 'B4': 2, 'E4': 5, 'C6': 3, 'E7': 6, ...ademas};
  return Tablero.mapaOriginal().conValores({
    for (final MapEntry(key: notacion, value: valor) in valores.entries) pos(notacion): valor,
  });
}

/// Todo el tablero lleno menos [libre]. Las casillas sin valor en [valores]
/// llevan un 1; no se revisan las reglas al llenarlo.
Tablero llenoMenos(String libre, {Map<String, int> valores = const {}}) {
  final base = Tablero.mapaOriginal();
  return base.conValores({
    for (final celda in base.celdas)
      if (celda.posicion != pos(libre)) celda.posicion: valores[celda.posicion.notacion] ?? 1,
  });
}

/// E5 es la última casilla libre. Su zona roja ya tiene del 1 al 5, así que
/// solo el 6 cabe, y sus vecinas tienen 1 (E4, D5, F5) y 2 (E6).
Tablero soloCabeElSeisEnE5() =>
    llenoMenos('E5', valores: {'F5': 1, 'E6': 2, 'D6': 3, 'D7': 4, 'E7': 5});

/// Un dado que va sacando [caras] en orden, para que los tests sepan qué sale.
int Function() dadoConCaras(List<int> caras) {
  var siguiente = 0;
  return () => caras[siguiente++ % caras.length];
}

/// Un [PartidaBloc] sobre [tablero] (por defecto, el de la Partida 1) cuyos
/// dados sacan [caras]. Por defecto salen 4 y 3: con el 4 como dado ancla, el
/// 3 va junto al 4 de C1.
PartidaBloc partidaBloc({Tablero? tablero, List<int> caras = const [4, 3]}) =>
    PartidaBloc(tablero ?? tableroPartida1(), tirarDado: dadoConCaras(caras));

/// [evaluarJugada] con la casilla escrita en notación del manual.
ResultadoJugada evaluarEn(
  Tablero tablero,
  String notacion, {
  required int ancla,
  required int valor,
}) =>
    evaluarJugada(tablero, pos(notacion), ancla: ancla, valor: valor);
