import 'dart:math';

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

  /// Cuándo llegó [vista] del servidor, y la hora de la última vez que se le preguntó.
  /// Con ellas se descuenta el tiempo de la ronda mientras el servidor contesta "no
  /// cambió nada" (304), que no trae los segundos nuevos.
  final DateTime? recibida;
  final DateTime? ahora;

  const SalaState({
    this.vista,
    this.ocupado = false,
    this.error,
    this.conexion = Conexion.conectada,
    this.fin = FinDeSala.ninguno,
    this.recibida,
    this.ahora,
  });

  /// Los segundos que le quedan a la ronda (o a la preparación): los que dijo el servidor
  /// al mandar [vista], menos lo que pasó desde entonces.
  double? get segundosQueQuedan {
    final segundos = vista?.segundosRestantes;
    final desde = recibida;
    final hasta = ahora;
    if (segundos == null || desde == null || hasta == null) return segundos;
    return max(0, segundos - hasta.difference(desde).inMilliseconds / 1000);
  }

  bool get enSala => vista != null && fin == FinDeSala.ninguno;

  SalaState copiaCon({
    VistaDeSala? vista,
    bool? ocupado,
    String? Function()? error,
    Conexion? conexion,
    FinDeSala? fin,
    DateTime? recibida,
    DateTime? ahora,
  }) {
    return SalaState(
      vista: vista ?? this.vista,
      ocupado: ocupado ?? this.ocupado,
      error: error == null ? this.error : error(),
      conexion: conexion ?? this.conexion,
      fin: fin ?? this.fin,
      recibida: recibida ?? this.recibida,
      ahora: ahora ?? this.ahora,
    );
  }
}
