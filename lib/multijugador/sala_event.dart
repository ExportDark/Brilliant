/// Lo que la app le pide al [SalaBloc].
sealed class SalaEvent {
  const SalaEvent();
}

/// Crear una sala y entrar a ella como anfitrión.
final class SalaCreada extends SalaEvent {
  const SalaCreada();
}

/// Entrar a una sala con el código que dictó quien la creó.
final class UnirseConCodigo extends SalaEvent {
  final String codigo;

  const UnirseConCodigo(this.codigo);
}

/// El anfitrión elige el mapa, antes de empezar.
final class MapaElegido extends SalaEvent {
  final int nivel;

  const MapaElegido(this.nivel);
}

/// El anfitrión empieza la partida.
final class PartidaEmpezada extends SalaEvent {
  const PartidaEmpezada();
}

/// Los números iniciales: casilla -> número del 1 al 6.
final class PreparacionEnviada extends SalaEvent {
  final Map<String, int> valores;

  const PreparacionEnviada(this.valores);
}

/// Anotar el otro dado en [casilla], pegada a una casilla con el [dadoAncla].
final class JugadaEnviada extends SalaEvent {
  final int dadoAncla;
  final String casilla;

  const JugadaEnviada({required this.dadoAncla, required this.casilla});
}

/// Pasar el turno (solo se puede si no hay jugada con esta tirada).
final class RondaPasada extends SalaEvent {
  const RondaPasada();
}

/// Salirse de la sala o rendirse. En la partida, queda fuera.
final class Rendirse extends SalaEvent {
  const Rendirse();
}

/// Preguntarle al servidor cómo va la sala. El bloc lo manda solo cada segundo; preguntar
/// es lo que le dice al servidor que este jugador sigue conectado.
final class Preguntar extends SalaEvent {
  const Preguntar();
}

/// Olvidar el error que se estaba mostrando.
final class ErrorDescartado extends SalaEvent {
  const ErrorDescartado();
}
