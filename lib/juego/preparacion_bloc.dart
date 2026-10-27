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
/// [admite] dice si una casilla acepta un número al empezar: en el Nivel 4,
/// una inicial cae en la zona naranja "4-6" y otra en la "1-3". Sin él,
/// cualquier número cabe en cualquier casilla.
class PreparacionBloc extends Bloc<PreparacionEvent, PreparacionState> {
  /// Cuántas veces se revuelve, como mucho, buscando un reparto al azar en
  /// el que cada número quepa en su casilla.
  static const _intentosDeReparto = 100;

  final Random _azar;
  final bool Function(Posicion casilla, int valor) _admite;

  PreparacionBloc(
    List<Posicion> casillas, {
    Random? azar,
    bool Function(Posicion casilla, int valor)? admite,
  })  : _azar = azar ?? Random(),
        _admite = admite ?? _cualquiera,
        super(PreparacionState(casillas: List.unmodifiable(casillas))) {
    on<ValorAsignado>(_alAsignarValor);
    on<ValorQuitado>(_alQuitarValor);
    on<RepartoAleatorio>(_alRepartirAlAzar);
    on<PreparacionConfirmada>(_alConfirmar);
    on<PreparacionReiniciada>(_alReiniciar);
  }

  static bool _cualquiera(Posicion casilla, int valor) => true;

  /// Si [casilla] acepta [valor] al empezar. La pantalla lo usa para apagar
  /// los números que no caben en la casilla seleccionada.
  bool admite(Posicion casilla, int valor) => _admite(casilla, valor);

  void _alAsignarValor(ValorAsignado event, Emitter<PreparacionState> emit) {
    if (state.confirmada) return;
    if (!state.casillas.contains(event.casilla)) return;
    if (!valoresPosibles.contains(event.valor)) return;
    if (!_admite(event.casilla, event.valor)) return;

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
    final puestos = state.completa ? <Posicion, int>{} : state.valores;
    final vacias = [
      for (final casilla in state.casillas)
        if (!puestos.containsKey(casilla)) casilla,
    ];
    final faltantes = valoresPosibles.difference(puestos.values.toSet()).toList();

    // Si lo ya puesto no deja completar el reparto (por ejemplo, ya se usaron
    // el 4, el 5 y el 6, y la inicial de la zona "4-6" sigue vacía), se
    // revuelve todo desde cero.
    final repartido = _repartirAlAzar(vacias, faltantes);
    final valores = repartido != null
        ? {...puestos, ...repartido}
        : _repartirAlAzar(state.casillas, valoresPosibles.toList());
    if (valores == null) return;

    emit(state.copiaCon(valores: valores));
  }

  /// Reparte [numeros] entre [casillas] al azar, uno en cada una, de modo que
  /// cada número quepa en su casilla. Devuelve `null` si no lo encuentra.
  Map<Posicion, int>? _repartirAlAzar(List<Posicion> casillas, List<int> numeros) {
    for (var intento = 0; intento < _intentosDeReparto; intento++) {
      numeros.shuffle(_azar);
      final reparto = {
        for (final (indice, casilla) in casillas.indexed) casilla: numeros[indice],
      };
      if (reparto.entries.every((asignacion) => _admite(asignacion.key, asignacion.value))) {
        return reparto;
      }
    }
    return null;
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
