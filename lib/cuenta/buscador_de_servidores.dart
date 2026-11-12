import 'buscador_de_servidores_web.dart' if (dart.library.io) 'buscador_de_servidores_io.dart'
    as plataforma;

/// Un servidor de cuentas que se anunció en la red local.
class ServidorEncontrado {
  /// Cómo se anuncia, por ejemplo "Brilliant en ORION".
  final String nombre;
  final Uri direccion;

  const ServidorEncontrado({required this.nombre, required this.direccion});

  @override
  bool operator ==(Object other) =>
      other is ServidorEncontrado && other.nombre == nombre && other.direccion == direccion;

  @override
  int get hashCode => Object.hash(nombre, direccion);

  @override
  String toString() => 'ServidorEncontrado($nombre, $direccion)';
}

/// Busca en la red local los servidores de cuentas que se anuncian, con
/// mDNS / DNS-SD (el servicio `_brilliant._tcp`, que anuncia
/// `Brilliant-servidor/servir.py`). Así la app encuentra el servidor sola, aunque la PC
/// cambie de red y de IP.
abstract interface class BuscadorDeServidores {
  /// Si en esta plataforma se puede buscar. En la web no: el navegador no deja.
  bool get puedeBuscar;

  /// Los servidores que se anunciaron mientras se buscó.
  Future<List<ServidorEncontrado>> buscar();
}

/// Uno que no busca: para la web, y para los tests que no lo necesitan.
class SinBuscar implements BuscadorDeServidores {
  const SinBuscar();

  @override
  bool get puedeBuscar => false;

  @override
  Future<List<ServidorEncontrado>> buscar() async => const [];
}

/// Varios buscadores a la vez: junta lo que encuentran todos. Si uno falla, cuentan los
/// demás.
class BuscadorCombinado implements BuscadorDeServidores {
  final List<BuscadorDeServidores> buscadores;

  const BuscadorCombinado(this.buscadores);

  @override
  bool get puedeBuscar => buscadores.any((b) => b.puedeBuscar);

  @override
  Future<List<ServidorEncontrado>> buscar() async {
    final resultados = await Future.wait([
      for (final buscador in buscadores)
        if (buscador.puedeBuscar)
          buscador.buscar().catchError((Object _) => const <ServidorEncontrado>[]),
    ]);
    return [for (final encontrados in resultados) ...encontrados];
  }
}

/// El buscador de esta plataforma: en Android, el descubrimiento de servicios
/// del sistema; en la web, ninguno.
BuscadorDeServidores crearBuscador() => plataforma.crearBuscador();
