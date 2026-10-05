import '../modelo/posicion.dart';
import '../modelo/tablero.dart';
import 'preparacion_state.dart' show valoresPosibles;
import 'validacion_jugada.dart';

/// Cómo va la partida: el tablero, la tirada del turno y el dado ancla.
///
/// De los dos dados, el ancla dice junto a qué casillas se puede jugar (las
/// que tienen ese número) y el otro es el número que se anota.
class PartidaState {
  final Tablero tablero;

  /// Los dos dados del turno, o `null` si todavía no se tiraron.
  final List<int>? dados;

  /// Cuál de los dos dados es el ancla (0 o 1), o `null` si ninguno.
  final int? dadoElegido;

  /// El número del turno en curso, empezando por 1.
  final int turno;

  const PartidaState({
    required this.tablero,
    this.dados,
    this.dadoElegido,
    this.turno = 1,
  });

  /// El número del dado ancla, o `null` si todavía no se eligió.
  int? get valorAncla {
    final dados = this.dados;
    final indice = dadoElegido;
    if (dados == null || indice == null) return null;
    return dados[indice];
  }

  /// El número que se anota: el del otro dado. `null` sin ancla elegida.
  int? get valorAColocar {
    final dados = this.dados;
    final indice = dadoElegido;
    if (dados == null || indice == null) return null;
    return dados[1 - indice];
  }

  /// Qué pasaría al anotar [valorAColocar] en [posicion], o `null` si
  /// todavía no hay ancla elegida.
  ResultadoJugada? evaluar(Posicion posicion) {
    final ancla = valorAncla;
    final valor = valorAColocar;
    if (ancla == null || valor == null) return null;
    return evaluarJugada(tablero, posicion, ancla: ancla, valor: valor);
  }

  /// Verdadero si la casilla de [posicion] tiene el número ancla.
  bool esAncla(Posicion posicion) {
    final ancla = valorAncla;
    return ancla != null && tablero.celdaEn(posicion)?.valor == ancla;
  }

  /// Verdadero cuando ya se tiró y no hay jugada con ninguno de los dos
  /// dados como ancla: solo queda pasar el turno.
  bool get sinJugada {
    final dados = this.dados;
    if (dados == null) return false;
    final [primero, segundo] = dados;
    return !hayJugada(tablero, ancla: primero, valor: segundo) &&
        !hayJugada(tablero, ancla: segundo, valor: primero);
  }

  /// Verdadero cuando ninguna tirada posible tiene jugada: no hay ancla y
  /// número del 1 al 6 que quepan en ningún lado.
  bool get terminada => !valoresPosibles.any(
        (ancla) => valoresPosibles.any(
          (valor) => hayJugada(tablero, ancla: ancla, valor: valor),
        ),
      );

  /// Cuántas casillas del tablero tienen número, contando las iniciales.
  int get casillasLlenas => tablero.celdas.where((celda) => !celda.estaVacia).length;
}
