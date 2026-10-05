import 'dart:math';

import 'package:bloc/bloc.dart';

import '../modelo/tablero.dart';
import 'partida_event.dart';
import 'partida_state.dart';
import 'validacion_jugada.dart';

/// Administra los turnos de la partida: tirar los dos dados, elegir uno como
/// ancla y anotar el otro pegado (arriba, abajo, izquierda o derecha) a una
/// casilla que tenga el número del ancla, donde la regla de su zona lo
/// permita.
///
/// Es un bloc local, acotado a la pantalla de partida: recibe el tablero con
/// los valores iniciales ya puestos. Cada número anotado cierra el turno.
/// Si no hay jugada con ninguno de los dos dados como ancla, el turno se
/// puede pasar.
///
/// Los eventos inválidos se ignoran sin emitir estado.
///
/// [tirarDado] devuelve una cara del 1 al 6; los tests le pasan una secuencia
/// fija.
class PartidaBloc extends Bloc<PartidaEvent, PartidaState> {
  final int Function() _tirarDado;

  PartidaBloc(Tablero tablero, {int Function()? tirarDado})
      : _tirarDado = tirarDado ?? _dadoAlAzar(Random()),
        super(PartidaState(tablero: tablero)) {
    on<DadosTirados>(_alTirar);
    on<DadoElegido>(_alElegirDado);
    on<ValorColocado>(_alColocar);
    on<TurnoPasado>(_alPasar);
  }

  static int Function() _dadoAlAzar(Random azar) => () => azar.nextInt(6) + 1;

  void _alTirar(DadosTirados event, Emitter<PartidaState> emit) {
    // Una tirada por turno: hasta colocar o pasar no se vuelve a tirar.
    if (state.dados != null) return;
    if (state.terminada) return;

    emit(PartidaState(
      tablero: state.tablero,
      dados: [_tirarDado(), _tirarDado()],
      turno: state.turno,
    ));
  }

  void _alElegirDado(DadoElegido event, Emitter<PartidaState> emit) {
    final dados = state.dados;
    if (dados == null) return;
    if (event.indice < 0 || event.indice >= dados.length) return;

    emit(PartidaState(
      tablero: state.tablero,
      dados: dados,
      dadoElegido: event.indice,
      turno: state.turno,
    ));
  }

  void _alColocar(ValorColocado event, Emitter<PartidaState> emit) {
    final valor = state.valorAColocar;
    if (valor == null) return;
    if (state.tablero.celdaEn(event.posicion) == null) return;
    if (state.evaluar(event.posicion) is! JugadaValida) return;

    emit(PartidaState(
      tablero: state.tablero.conValor(event.posicion, valor),
      turno: state.turno + 1,
    ));
  }

  void _alPasar(TurnoPasado event, Emitter<PartidaState> emit) {
    if (!state.sinJugada) return;

    emit(PartidaState(tablero: state.tablero, turno: state.turno + 1));
  }
}
