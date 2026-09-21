import '../modelo/posicion.dart';

/// Lo que el jugador puede intentar hacer durante una partida.
sealed class PartidaEvent {
  const PartidaEvent();
}

/// Arranca una partida nueva: tablero vacío, en fase de preparación.
class PartidaIniciada extends PartidaEvent {
  const PartidaIniciada();
}

/// Anota uno de los números del 1 al 6 en una de las 6 casillas iniciales.
class ValorInicialAsignado extends PartidaEvent {
  final Posicion posicion;
  final int valor;

  const ValorInicialAsignado(this.posicion, this.valor);
}

/// Libera una casilla inicial ya asignada, para poder repartir de otra forma.
class ValorInicialQuitado extends PartidaEvent {
  final Posicion posicion;

  const ValorInicialQuitado(this.posicion);
}

/// Intenta cerrar la preparación y pasar a jugar. Solo procede si las 6
/// casillas iniciales ya tienen valor.
class PreparacionConfirmada extends PartidaEvent {
  const PreparacionConfirmada();
}
