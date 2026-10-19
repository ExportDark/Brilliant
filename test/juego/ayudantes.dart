// Ayudantes compartidos por los tests de `juego/`. No termina en `_test.dart`,
// así que `flutter test` no lo corre: solo lo importan los tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_bloc.dart';
import 'package:brilliant/juego/partida_event.dart';
import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/extraer_valores.dart';
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

/// Un dado sin azar que recorre en orden las 36 combinaciones de dos dados:
/// (1,1), (1,2), …, (6,6), y vuelve a empezar. Como el dado ancla puede ser
/// cualquiera de los dos, cualquier jugada que haga falta sale a más tardar en
/// 36 turnos: una partida con estos dados siempre avanza.
int Function() dadosConTodasLasCombinaciones() => dadoConCaras([
      for (var primero = 1; primero <= 6; primero++)
        for (var segundo = 1; segundo <= 6; segundo++) ...[primero, segundo],
    ]);

/// Un [PartidaBloc] sobre [tablero] (por defecto, el de la Partida 1) cuyos
/// dados sacan [caras]. Por defecto salen 4 y 3: con el 4 como dado ancla, el
/// 3 va junto al 4 de C1.
PartidaBloc partidaBloc({Tablero? tablero, List<int> caras = const [4, 3]}) =>
    PartidaBloc(tablero ?? tableroPartida1(), tirarDado: dadoConCaras(caras));

/// Las casillas de [tablero] que cumplen [condicion], en notación del manual.
Set<String> casillasDonde(Tablero tablero, bool Function(Posicion) condicion) => {
      for (final celda in tablero.celdas)
        if (condicion(celda.posicion)) celda.posicion.notacion,
    };

/// Dónde se puede anotar [valor] cuando el dado ancla sacó [ancla].
Set<String> posiblesEn(Tablero tablero, {required int ancla, required int valor}) =>
    casillasDonde(
      tablero,
      (posicion) => evaluarJugada(tablero, posicion, ancla: ancla, valor: valor) is JugadaValida,
    );

/// Las casillas junto a un número buscado donde la regla de color no deja
/// anotar [valor]: las que la pantalla ilumina apenas.
Set<String> bloqueadasEn(Tablero tablero, {required int ancla, required int valor}) =>
    casillasDonde(
      tablero,
      (posicion) => evaluarJugada(tablero, posicion, ancla: ancla, valor: valor) is ReglaRota,
    );

/// Manda [evento] y espera a que el bloc lo procese.
Future<void> enviar(PartidaBloc bloc, PartidaEvent evento) async {
  bloc.add(evento);
  await Future<void>.delayed(Duration.zero);
}

/// Juega la partida entera como un jugador automático: tira, pasa el turno si
/// no hay jugada, y si la hay elige como dado ancla el que tenga jugada y
/// anota en la primera casilla válida. Cada jugada tiene que ser aceptada.
///
/// Devuelve cuántos números anotó y cuántos turnos pasó. [contexto] va en los
/// mensajes de error, para saber qué partida falló. Si pasa de [maximoTurnos],
/// el test falla: el bloc se quedaría pasando turnos para siempre.
Future<({int colocadas, int pasados})> jugarHastaElFinal(
  PartidaBloc bloc, {
  required String contexto,
  int maximoTurnos = 2000,
}) async {
  var colocadas = 0;
  var pasados = 0;

  while (!bloc.state.terminada) {
    if (bloc.state.turno > maximoTurnos) {
      fail('$contexto: la partida no terminó en $maximoTurnos turnos');
    }

    await enviar(bloc, const DadosTirados());
    final tirada = bloc.state;
    if (tirada.sinJugada) {
      await enviar(bloc, const TurnoPasado());
      pasados++;
      continue;
    }

    final [primero, segundo] = tirada.dados!;
    final ancla = hayJugada(tirada.tablero, ancla: primero, valor: segundo) ? 0 : 1;
    await enviar(bloc, DadoElegido(ancla));

    final anclado = bloc.state;
    final destino = anclado.tablero.celdas
        .map((celda) => celda.posicion)
        .firstWhere((posicion) => anclado.evaluar(posicion) is JugadaValida);
    await enviar(bloc, ValorColocado(destino));

    expect(
      bloc.state.turno,
      anclado.turno + 1,
      reason: '$contexto: la jugada en ${destino.notacion} debió aceptarse',
    );
    expect(bloc.state.tablero.celdaEn(destino)!.valor, anclado.valorAColocar);
    colocadas++;
  }

  return (colocadas: colocadas, pasados: pasados);
}

/// Comprueba que cada zona de [tablero] cumpla su regla de color: metiendo
/// sus valores uno por uno, la regla tiene que aceptarlos todos.
void expectZonasCumplenSusReglas(Tablero tablero, {required String contexto}) {
  for (final region in tablero.regiones) {
    final valores = extraerValores(region);
    for (var i = 0; i < valores.length; i++) {
      expect(
        region.tipo.regla.puedeAgregar(valores.sublist(0, i), valores[i]),
        isTrue,
        reason: '$contexto: la zona #${region.identificador} '
            '(${region.tipo.color.name}) quedó con $valores',
      );
    }
  }
}

/// [evaluarJugada] con la casilla escrita en notación del manual.
ResultadoJugada evaluarEn(
  Tablero tablero,
  String notacion, {
  required int ancla,
  required int valor,
}) =>
    evaluarJugada(tablero, pos(notacion), ancla: ancla, valor: valor);
