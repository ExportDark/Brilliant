import 'modelos.dart';

/// Cómo va la conexión con el servidor. El servidor deja fuera a quien pasa 10 segundos
/// sin preguntar, así que la app avisa antes de que eso pase.
enum Conexion {
  conectada,

  /// Llevamos unos segundos sin respuesta: se está reintentando.
  reconectando,

  /// Llevamos 10 segundos sin respuesta: el servidor ya nos pudo haber sacado.
  perdida,
}

/// Por qué ya no se está en una sala.
enum FinDeSala {
  ninguno,

  /// El servidor ya no tiene esa sala (se reinició, o se cerró hace rato).
  desaparecio,

  /// El servidor dice que ya no estamos en ella (salimos del lobby, o nos sacó).
  saliste,
}

/// El estado del multijugador: la sala en la que se está, si hay un pedido en curso, el
/// último error y cómo va la conexión.
class SalaState {
  /// La sala como la ve este jugador, o `null` si no está en ninguna.
  final VistaDeSala? vista;

  /// Hay un pedido en curso (crear, unirse, jugar...): los botones esperan.
  final bool ocupado;

  /// Lo que hay que decirle al jugador sobre el último pedido que falló, si algo.
  final String? error;

  final Conexion conexion;
  final FinDeSala fin;

  const SalaState({
    this.vista,
    this.ocupado = false,
    this.error,
    this.conexion = Conexion.conectada,
    this.fin = FinDeSala.ninguno,
  });

  bool get enSala => vista != null && fin == FinDeSala.ninguno;

  SalaState copiaCon({
    VistaDeSala? vista,
    bool? ocupado,
    String? Function()? error,
    Conexion? conexion,
    FinDeSala? fin,
  }) {
    return SalaState(
      vista: vista ?? this.vista,
      ocupado: ocupado ?? this.ocupado,
      error: error == null ? this.error : error(),
      conexion: conexion ?? this.conexion,
      fin: fin ?? this.fin,
    );
  }
}
