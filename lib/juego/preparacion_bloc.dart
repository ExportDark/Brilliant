import 'dart:math';

import 'package:bloc/bloc.dart';

import '../modelo/posicion.dart';
import 'preparacion_event.dart';
import 'preparacion_state.dart';

/// Administra el reparto de los valores iniciales, el paso previo a jugar.
///
/// El jugador anota un número del 1 al 6 en cada una de las casillas
/// iniciales, sin repetir ninguno. La partida no puede empezar hasta que
/// estén todas llenas: mientras falte alguna, [PreparacionConfirmada] no
/// hace nada.
///
/// Es un bloc local, acotado a la pantalla de preparación: recibe en el
/// constructor las casillas a llenar y no conoce el tablero. Al terminar
/// entrega las asignaciones en [PreparacionState.valores].
///
/// Los eventos inválidos se ignoran sin emitir estado.
///
/// [azar] decide el [RepartoAleatorio]; los tests lo pasan con semilla fija.
class PreparacionBloc extends Bloc<PreparacionEvent, PreparacionState> {
  final Random _azar;

  PreparacionBloc(List<Posicion> casillas, {Random? azar})
      : _azar = azar ?? Random(),
        super(PreparacionState(casillas: List.unmodifiable(casillas))) {
    on<ValorAsignado>(_alAsignarValor);
    on<ValorQuitado>(_alQuitarValor);
    on<RepartoAleatorio>(_alRepartirAlAzar);
    on<PreparacionConfirmada>(_alConfirmar);
    on<PreparacionReiniciada>(_alReiniciar);
  }

  void _alAsignarValor(ValorAsignado event, Emitter<PreparacionState> emit) {
    if (state.confirmada) return;
    if (!state.casillas.contains(event.casilla)) return;
    if (!valoresPosibles.contains(event.valor)) return;

    final usadoEnOtraCasilla = state.valores.entries.any(
      (asignacion) =>
          asignacion.value == event.valor && asignacion.key != event.casilla,
    );
    if (usadoEnOtraCasilla) return;

    emit(state.copiaCon(valores: {...state.valores, event.casilla: event.valor}));
  }

  void _alQuitarValor(ValorQuitado event, Emitter<PreparacionState> emit) {
    if (state.confirmada) return;
    if (!state.valores.containsKey(event.casilla)) return;

    emit(state.copiaCon(valores: {...state.valores}..remove(event.casilla)));
  }

  void _alRepartirAlAzar(RepartoAleatorio event, Emitter<PreparacionState> emit) {
    if (state.confirmada) return;

    // Con todas llenas no queda nada que completar: se revuelve desde cero.
    final valores = state.completa ? <Posicion, int>{} : {...state.valores};
    final vacias = state.casillas.where((casilla) => !valores.containsKey(casilla));
    final numeros = valoresPosibles.difference(valores.values.toSet()).toList()
      ..shuffle(_azar);

    for (final (indice, casilla) in vacias.indexed) {
      valores[casilla] = numeros[indice];
    }

    emit(state.copiaCon(valores: valores));
  }

  void _alConfirmar(PreparacionConfirmada event, Emitter<PreparacionState> emit) {
    if (state.confirmada) return;

    // Sin todas las casillas llenas, la partida no puede empezar.
    if (!state.completa) return;

    emit(state.copiaCon(confirmada: true));
  }

  void _alReiniciar(PreparacionReiniciada event, Emitter<PreparacionState> emit) {
    emit(PreparacionState(casillas: state.casillas));
  }
}
