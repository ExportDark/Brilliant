import 'buscador_de_servidores.dart';

/// Si se puede hablar con el servidor de cuentas.
enum Disponibilidad {
  /// Se está revisando si contesta, o buscándolo en la red.
  revisando,

  /// Contesta: se puede entrar o crear la cuenta.
  disponible,

  /// No contesta, y en la red no se encontró otro.
  noDisponible,

  /// En la red contestan varios y no se puede elegir uno solo: cada uno tiene sus
  /// cuentas. El jugador elige de [ServidorState.encontrados].
  variosEncontrados,
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

  /// Los servidores que contestaron en la última búsqueda en la red.
  final List<ServidorEncontrado> encontrados;

  const ServidorState({
    required this.direccion,
    this.disponibilidad = Disponibilidad.revisando,
    this.nombre,
    this.encontrados = const [],
  });

  ServidorState con({Disponibilidad? disponibilidad, List<ServidorEncontrado>? encontrados}) =>
      ServidorState(
        direccion: direccion,
        disponibilidad: disponibilidad ?? this.disponibilidad,
        nombre: nombre,
        encontrados: encontrados ?? this.encontrados,
      );

  @override
  bool operator ==(Object other) =>
      other is ServidorState &&
      other.direccion == direccion &&
      other.disponibilidad == disponibilidad &&
      other.nombre == nombre &&
      _iguales(other.encontrados, encontrados);

  static bool _iguales(List<ServidorEncontrado> a, List<ServidorEncontrado> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(direccion, disponibilidad, nombre, Object.hashAll(encontrados));

  @override
  String toString() => 'ServidorState($direccion, ${disponibilidad.name}, $nombre)';
}
