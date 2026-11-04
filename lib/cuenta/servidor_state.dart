/// Si se puede hablar con el servidor de cuentas.
enum Disponibilidad {
  /// Se está revisando si contesta, o buscándolo en la red.
  revisando,

  /// Contesta: se puede entrar o crear la cuenta.
  disponible,

  /// No contesta, y en la red no se encontró otro.
  noDisponible,
}

/// Dónde está el servidor de cuentas y si contesta, para mostrarlo en la
/// pantalla.
class ServidorState {
  final Uri direccion;
  final Disponibilidad disponibilidad;

  /// Cómo se anuncia en la red, por ejemplo "Brilliant en ORION". Solo se
  /// sabe si se llegó a él buscándolo; si la dirección se escribió a mano, es
  /// `null`.
  final String? nombre;

  const ServidorState({
    required this.direccion,
    this.disponibilidad = Disponibilidad.revisando,
    this.nombre,
  });

  ServidorState con({Disponibilidad? disponibilidad}) => ServidorState(
        direccion: direccion,
        disponibilidad: disponibilidad ?? this.disponibilidad,
        nombre: nombre,
      );

  @override
  bool operator ==(Object other) =>
      other is ServidorState &&
      other.direccion == direccion &&
      other.disponibilidad == disponibilidad &&
      other.nombre == nombre;

  @override
  int get hashCode => Object.hash(direccion, disponibilidad, nombre);

  @override
  String toString() => 'ServidorState($direccion, ${disponibilidad.name}, $nombre)';
}
