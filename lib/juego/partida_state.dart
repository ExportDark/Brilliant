import '../modelo/posicion.dart';
import '../modelo/tablero.dart';
import 'preparacion_state.dart' show valoresPosibles;
import 'validacion_jugada.dart';

/// Cómo va la partida: el tablero, la tirada del turno y el dado anclado.
class PartidaState {
  final Tablero tablero;

  /// Los dos dados del turno, o `null` si todavía no se tiraron.
  final List<int>? dados;

  /// Cuál de los dos dados está anclado (0 o 1), o `null` si ninguno.
  final int? dadoElegido;

  /// El número del turno en curso, empezando por 1.
  final int turno;

  const PartidaState({
    required this.tablero,
    this.dados,
    this.dadoElegido,
    this.turno = 1,
  });

  /// El número del dado anclado, o `null` si no hay ninguno.
  int? get valorElegido {
    final dados = this.dados;
    final indice = dadoElegido;
    if (dados == null || indice == null) return null;
    return dados[indice];
  }

  /// Qué pasaría al anotar el dado anclado en [posicion], o `null` si no hay
  /// ningún dado anclado.
  ResultadoJugada? evaluar(Posicion posicion) {
    final valor = valorElegido;
    if (valor == null) return null;
    return evaluarJugada(tablero, posicion, valor);
  }

  /// Verdadero cuando ya se tiró y ninguno de los dos dados cabe en ningún
  /// lado: solo queda pasar el turno.
  bool get sinJugada {
    final dados = this.dados;
    return dados != null && !dados.any((dado) => hayLugarPara(tablero, dado));
  }

  /// Verdadero cuando ya ninguna casilla acepta ningún número del 1 al 6.
  bool get terminada => !valoresPosibles.any((valor) => hayLugarPara(tablero, valor));

  /// Cuántas casillas del tablero tienen número, contando las iniciales.
  int get casillasLlenas => tablero.celdas.where((celda) => !celda.estaVacia).length;
}
