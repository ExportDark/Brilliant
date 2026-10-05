import '../modelo/posicion.dart';

/// Lo que el jugador puede hacer durante la partida.
sealed class PartidaEvent {
  const PartidaEvent();
}

/// Tira los dos dados del turno.
class DadosTirados extends PartidaEvent {
  const DadosTirados();
}

/// Elige uno de los dos dados ([indice] 0 o 1) como ancla: el otro se
/// anotará junto a una casilla que tenga el número del ancla. Mientras no se
/// coloque, se puede elegir el otro.
class DadoElegido extends PartidaEvent {
  final int indice;

  const DadoElegido(this.indice);
}

/// Anota el dado que no es el ancla en [posicion], si está pegada a una
/// casilla con el número ancla y la regla de su zona lo permite.
class ValorColocado extends PartidaEvent {
  final Posicion posicion;

  const ValorColocado(this.posicion);
}

/// Deja pasar el turno cuando ninguno de los dos dados cabe en el tablero.
class TurnoPasado extends PartidaEvent {
  const TurnoPasado();
}
