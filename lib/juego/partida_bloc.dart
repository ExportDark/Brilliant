import 'package:bloc/bloc.dart';

import '../modelo/tablero.dart';
import 'fase_partida.dart';
import 'partida_event.dart';
import 'partida_state.dart';

/// Lleva el estado de una partida.
///
/// Arranca en [FasePartida.preparando], donde el jugador reparte los números
/// del 1 al 6 entre las 6 casillas iniciales. La partida no avanza a
/// [FasePartida.jugando] hasta que esas 6 casillas tengan valor: mientras
/// falte alguna, [PreparacionConfirmada] no hace nada.
///
/// Los eventos inválidos se ignoran sin emitir estado.
class PartidaBloc extends Bloc<PartidaEvent, PartidaState> {
  PartidaBloc() : super(_partidaNueva()) {
    on<PartidaIniciada>(_alIniciarPartida);
    on<ValorInicialAsignado>(_alAsignarValorInicial);
    on<ValorInicialQuitado>(_alQuitarValorInicial);
    on<PreparacionConfirmada>(_alConfirmarPreparacion);
  }

  static PartidaState _partidaNueva() {
    return PartidaState(
      tablero: Tablero.mapaOriginal(),
      fase: FasePartida.preparando,
    );
  }

  void _alIniciarPartida(PartidaIniciada event, Emitter<PartidaState> emit) {
    emit(_partidaNueva());
  }

  void _alAsignarValorInicial(ValorInicialAsignado event, Emitter<PartidaState> emit) {
    if (state.fase != FasePartida.preparando) return;
    if (!valoresPosibles.contains(event.valor)) return;

    final celda = state.tablero.celdaEn(event.posicion);
    if (celda == null || !celda.esInicial) return;

    final usadosEnOtrasCasillas = state.casillasIniciales
        .where((otra) => otra.posicion != event.posicion)
        .map((otra) => otra.valor)
        .whereType<int>()
        .toSet();
    if (usadosEnOtrasCasillas.contains(event.valor)) return;

    emit(state.copiaCon(
      tablero: state.tablero.conValor(event.posicion, event.valor),
    ));
  }

  void _alQuitarValorInicial(ValorInicialQuitado event, Emitter<PartidaState> emit) {
    if (state.fase != FasePartida.preparando) return;

    final celda = state.tablero.celdaEn(event.posicion);
    if (celda == null || !celda.esInicial || celda.estaVacia) return;

    emit(state.copiaCon(tablero: state.tablero.sinValor(event.posicion)));
  }

  void _alConfirmarPreparacion(PreparacionConfirmada event, Emitter<PartidaState> emit) {
    if (state.fase != FasePartida.preparando) return;

    // El gate: sin las 6 casillas iniciales llenas, la partida no avanza.
    if (!state.preparacionCompleta) return;

    emit(state.copiaCon(fase: FasePartida.jugando));
  }
}
