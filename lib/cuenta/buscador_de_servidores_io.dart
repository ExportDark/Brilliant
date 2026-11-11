import 'dart:io';

import 'package:nsd/nsd.dart' as nsd;

import 'buscador_de_servidores.dart';
import 'direccion_del_servidor.dart';

BuscadorDeServidores crearBuscador() => const BuscadorNsd();

/// Busca con el descubrimiento de servicios de red del sistema (en Android,
/// `NsdManager`), a través del paquete nsd.
class BuscadorNsd implements BuscadorDeServidores {
  /// El tipo de servicio que anuncia `Brilliant-servidor/servir.py`.
  static const tipo = '_brilliant._tcp';

  /// Cuánto se escucha la red antes de contestar.
  final Duration espera;

  const BuscadorNsd({this.espera = const Duration(seconds: 3)});

  @override
  bool get puedeBuscar => true;

  @override
  Future<List<ServidorEncontrado>> buscar() async {
    final nsd.Discovery busqueda;
    try {
      busqueda = await nsd.startDiscovery(tipo, ipLookupType: nsd.IpLookupType.v4);
    } on Exception {
      // Sin WiFi, o el sistema no deja buscar: no se encontró nada.
      return const [];
    }

    try {
      await Future<void>.delayed(espera);
      return [for (final servicio in busqueda.services) ..._servidoresDe(servicio)];
    } finally {
      try {
        await nsd.stopDiscovery(busqueda);
      } on Exception {
        // Si ya se había detenido, no importa.
      }
    }
  }

  /// Un servicio puede anunciarse con varias IPs: una dirección por cada una.
  static List<ServidorEncontrado> _servidoresDe(nsd.Service servicio) => [
        for (final ip in servicio.addresses ?? const <InternetAddress>[])
          if (ip.type == InternetAddressType.IPv4)
            ServidorEncontrado(
              nombre: servicio.name ?? 'Brilliant',
              direccion: Uri(
                scheme: 'https',
                host: ip.address,
                port: servicio.port ?? puertoDelServidor,
                path: '/',
              ),
            ),
      ];
}
