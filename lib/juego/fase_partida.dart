/// Las fases por las que pasa una partida.
enum FasePartida {
  /// El jugador todavía está repartiendo los números 1-6 entre las 6 casillas
  /// iniciales. No se puede jugar hasta terminar esta fase.
  preparando,

  /// Se tiran los dados y se anotan valores en el resto del tablero.
  jugando,

  /// El tablero se llenó o ya no quedan jugadas legales.
  terminada,
}
