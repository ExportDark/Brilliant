import '../modelo/celda.dart';
import '../modelo/tablero.dart';
import 'fase_partida.dart';

/// Los valores que puede tomar una casilla: las caras de un dado de 6.
const valoresPosibles = {1, 2, 3, 4, 5, 6};

/// El estado de una partida. Solo guarda el tablero y la fase — todo lo demás
/// se deriva del tablero, para que no haya dos fuentes de verdad que puedan
/// desincronizarse.
class PartidaState {
  final Tablero tablero;
  final FasePartida fase;

  const PartidaState({required this.tablero, required this.fase});

  PartidaState copiaCon({Tablero? tablero, FasePartida? fase}) {
    return PartidaState(
      tablero: tablero ?? this.tablero,
      fase: fase ?? this.fase,
    );
  }

  /// Las 6 casillas fijas que se llenan antes de tirar los dados.
  Iterable<Celda> get casillasIniciales =>
      tablero.celdas.where((celda) => celda.esInicial);

  /// Los números ya repartidos entre las casillas iniciales.
  Set<int> get valoresInicialesUsados =>
      casillasIniciales.map((celda) => celda.valor).whereType<int>().toSet();

  /// Los números que todavía quedan por repartir.
  Set<int> get valoresDisponibles =>
      valoresPosibles.difference(valoresInicialesUsados);

  /// Verdadero cuando las 6 casillas iniciales ya tienen valor. Mientras sea
  /// falso, la partida no puede salir de la fase de preparación.
  bool get preparacionCompleta =>
      casillasIniciales.every((celda) => !celda.estaVacia);
}
