import 'dart:io';

import 'package:nsd/nsd.dart' as nsd;

import 'buscador_de_servidores.dart';
import 'direccion_del_servidor.dart';

/// En Android (y en la PC): mDNS y, a la vez, probar las direcciones de la red. El
/// anuncio mDNS lo bloquean el firewall de Windows y muchos routers o hotspots; probar el
/// puerto del servidor no, porque es el mismo que hace falta para jugar.
BuscadorDeServidores crearBuscador() =>
    BuscadorCombinado([const BuscadorNsd(), BuscadorPorBarrido()]);

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

/// Busca el servidor sin mDNS: toma la IP del aparato en la WiFi (por ejemplo
/// 192.168.1.37) y prueba el puerto del servidor en las otras 253 de su red
/// (192.168.1.1 a 192.168.1.254), muchas a la vez y con poca espera.
///
/// Encuentra direcciones, no nombres: los que contestan vuelven sin nombre, y el
/// `ServidorCubit` le pregunta a cada uno cómo se llama. Que sea un servidor de Brilliant
/// lo confirma el certificado: la app solo confía en el suyo.
class BuscadorPorBarrido implements BuscadorDeServidores {
  /// Cuántas direcciones se prueban a la vez.
  static const aLaVez = 48;

  /// Cuánto se espera a que cada una conteste.
  static const espera = Duration(milliseconds: 400);

  /// Las IPs de este aparato. Los tests ponen las suyas.
  final Future<List<String>> Function() misIps;

  /// Si en [ip] hay algo escuchando en el puerto del servidor. Los tests lo cambian.
  final Future<bool> Function(String ip) puertoAbierto;

  BuscadorPorBarrido({
    Future<List<String>> Function()? misIps,
    Future<bool> Function(String ip)? puertoAbierto,
  })  : misIps = misIps ?? ipsDeEsteAparato,
        puertoAbierto = puertoAbierto ?? abierto;

  @override
  bool get puedeBuscar => true;

  @override
  Future<List<ServidorEncontrado>> buscar() async {
    final mias = [for (final ip in await misIps()) if (esDeRedLocal(ip)) ip];
    // Con dos redes basta (la WiFi y, a lo sumo, el hotspot); más sería probar de más.
    final candidatas = <String>{
      for (final ip in mias.take(2)) ...vecinasDe(ip),
    }..removeAll(mias);

    final pendientes = [...candidatas];
    final abiertas = <String>[];
    Future<void> probar() async {
      while (pendientes.isNotEmpty) {
        final ip = pendientes.removeLast();
        if (await puertoAbierto(ip)) abiertas.add(ip);
      }
    }

    await Future.wait([for (var i = 0; i < aLaVez; i++) probar()]);
    abiertas.sort(_porNumero);
    return [
      for (final ip in abiertas)
        ServidorEncontrado(
          nombre: '',
          direccion: Uri(scheme: 'https', host: ip, port: puertoDelServidor, path: '/'),
        ),
    ];
  }

  /// Las IPv4 de este aparato, sin la de loopback.
  static Future<List<String>> ipsDeEsteAparato() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      return [
        for (final interfaz in interfaces)
          for (final direccion in interfaz.addresses)
            if (!direccion.isLoopback) direccion.address,
      ];
    } on Exception {
      return const [];
    }
  }

  /// Si [ip] está en un rango de red local (10.x, 172.16-31.x, 192.168.x). Las demás,
  /// como la de los datos móviles, no se recorren.
  static bool esDeRedLocal(String ip) {
    final partes = ip.split('.').map(int.tryParse).toList();
    if (partes.length != 4 || partes.any((p) => p == null || p < 0 || p > 255)) return false;
    final [a, b, ...] = partes;
    return a == 10 || (a == 172 && b! >= 16 && b <= 31) || (a == 192 && b == 168);
  }

  /// Las 254 direcciones de la red de [ip] (la misma red /24): de .1 a .254.
  static List<String> vecinasDe(String ip) {
    final prefijo = ip.substring(0, ip.lastIndexOf('.'));
    return [for (var n = 1; n <= 254; n++) '$prefijo.$n'];
  }

  /// Si algo escucha en el puerto del servidor en [ip].
  static Future<bool> abierto(String ip) async {
    try {
      final conexion = await Socket.connect(ip, puertoDelServidor, timeout: espera);
      conexion.destroy();
      return true;
    } on Exception {
      return false;
    }
  }

  static int _porNumero(String a, String b) => _numero(a).compareTo(_numero(b));

  static int _numero(String ip) =>
      ip.split('.').fold(0, (total, parte) => total * 256 + int.parse(parte));
}
