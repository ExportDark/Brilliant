import '../modelo/posicion.dart';

/// Lo que el jugador puede hacer durante la partida.
sealed class PartidaEvent {
  const PartidaEvent();
}

/// Tira los dos dados del turno.
class DadosTirados extends PartidaEvent {
  const DadosTirados();
}

/// Ancla uno de los dos dados ([indice] 0 o 1) como el número a anotar.
/// Mientras no se coloque, se puede anclar el otro.
class DadoElegido extends PartidaEvent {
  final int indice;

  const DadoElegido(this.indice);
}

/// Anota el dado anclado en [posicion], si la regla de su zona lo permite.
class ValorColocado extends PartidaEvent {
  final Posicion posicion;

  const ValorColocado(this.posicion);
}

/// Deja pasar el turno cuando ninguno de los dos dados cabe en el tablero.
class TurnoPasado extends PartidaEvent {
  const TurnoPasado();
}
