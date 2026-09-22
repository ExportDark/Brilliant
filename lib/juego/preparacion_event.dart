import '../modelo/posicion.dart';

/// Lo que el jugador puede hacer mientras reparte los valores iniciales.
sealed class PreparacionEvent {
  const PreparacionEvent();
}

/// Anota un número del 1 al 6 en una de las casillas iniciales.
class ValorAsignado extends PreparacionEvent {
  final Posicion casilla;
  final int valor;

  const ValorAsignado(this.casilla, this.valor);
}

/// Libera una casilla ya asignada, para poder repartir de otra forma.
class ValorQuitado extends PreparacionEvent {
  final Posicion casilla;

  const ValorQuitado(this.casilla);
}

/// Cierra la preparación. Solo procede si las casillas ya están todas llenas.
class PreparacionConfirmada extends PreparacionEvent {
  const PreparacionConfirmada();
}

/// Borra lo repartido y vuelve a empezar.
class PreparacionReiniciada extends PreparacionEvent {
  const PreparacionReiniciada();
}
